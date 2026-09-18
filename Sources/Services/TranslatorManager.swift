import Foundation
import SwiftUI
@preconcurrency import Translation

/// Manages on-device translation using Apple's native Translation framework.
/// The translation direction is derived from AppSettings (homeLanguage →
/// targetLanguage): an English speaker gets English→Portuguese, a Portuguese
/// speaker gets Portuguese→English.
///
/// The Translation framework requires a TranslationSession obtained via SwiftUI.
/// A hidden TranslationSessionView must be present in the view hierarchy.
/// The session is shared through a TranslationSessionHolder.
///
/// **Simulator Fallback:** When the real Translation session is unavailable
/// (e.g., on simulator where models can't be downloaded), a built-in mock
/// dictionary of ~150 common English→Portuguese word pairs is used automatically.
@MainActor
final class TranslatorManager: ObservableObject {
    // MARK: - Published State

    /// Language is at least supported (model downloadable).
    @Published var isModelDownloaded: Bool = false

    /// Language model is fully installed and ready for on-device use.
    /// Strictly true only when LanguageAvailability returns .installed.
    @Published var isModelInstalled: Bool = false
    @Published var downloadProgress: Float = 0.0
    @Published var isTranslating: Bool = false
    @Published var isSessionReady: Bool = false

    /// Whether the mock translator is currently being used (simulator fallback).
    @Published var isUsingMockTranslator: Bool = false

    /// Current connection status description for UI display.
    @Published var connectionStatus: String = ""

    // MARK: - Properties

    /// In-memory cache of recent translations.
    private(set) var cachedTranslations: [String: String] = [:]

    /// Number of translation model downloads performed.
    private(set) var downloadCount: Int = 0

    /// Date of the last model download.
    private(set) var lastDownloaded: Date?

    /// Shared session holder — set by TranslationSessionView.
    var sessionHolder: TranslationSessionHolder?

    /// BCP-47 source locale code (e.g. "en" or "pt"), derived from AppSettings.
    private(set) var sourceLanguageCode: String

    /// BCP-47 target locale code (e.g. "pt" or "en"), derived from AppSettings.
    private(set) var targetLanguageCode: String

    /// Source language for translation sessions, derived from AppSettings.
    @Published private(set) var sourceLanguage: Locale.Language

    /// Target language for translation sessions, derived from AppSettings.
    @Published private(set) var targetLanguage: Locale.Language

    // MARK: - Initialization

    /// Creates the translator with the direction stored in `settings`.
    /// When no settings are provided (or the language names are unknown), the
    /// original English→Portuguese default is preserved.
    init(settings: AppSettings? = nil) {
        let homeName = settings?.homeLanguage ?? "English"
        let targetName = settings?.targetLanguage ?? "Portuguese"
        sourceLanguageCode = Self.localeCode(forLanguageName: homeName) ?? "en"
        targetLanguageCode = Self.localeCode(forLanguageName: targetName) ?? "pt"
        sourceLanguage = Locale.Language(identifier: sourceLanguageCode)
        targetLanguage = Locale.Language(identifier: targetLanguageCode)
        checkModelStatus()
        // Start network monitoring on first use.
        NetworkMonitor.shared.start()
    }

    /// Maps a stored AppSettings language name to its BCP-47 locale code.
    /// Only the two supported languages have entries; unknown names fall back
    /// to the original English→Portuguese default.
    private static func localeCode(forLanguageName name: String) -> String? {
        switch name {
        case "English": return "en"
        case "Portuguese": return "pt"
        default: return nil
        }
    }

    /// Re-derives the translation direction from the persisted AppSettings.
    /// Called once the settings row is available so the translator honors the
    /// stored home/target languages instead of the built-in defaults.
    func updateDirection(from settings: AppSettings) {
        let newSourceCode = Self.localeCode(forLanguageName: settings.homeLanguage) ?? "en"
        let newTargetCode = Self.localeCode(forLanguageName: settings.targetLanguage) ?? "pt"
        guard newSourceCode != sourceLanguageCode || newTargetCode != targetLanguageCode else { return }
        sourceLanguageCode = newSourceCode
        targetLanguageCode = newTargetCode
        sourceLanguage = Locale.Language(identifier: newSourceCode)
        targetLanguage = Locale.Language(identifier: newTargetCode)
        // A flipped direction invalidates cached translations.
        clearCache()
        // Re-probe model availability for the new language pair.
        checkModelStatus()
    }

    // MARK: - Model Management

    /// Checks whether translation between source and target languages is available.
    /// With Apple's Translation framework, models are managed by the system.
    func checkModelStatus() {
        Task {
            #if targetEnvironment(simulator)
            // The simulator structurally cannot host Apple's on-device translation
            // models. Asking LanguageAvailability still connects to
            // com.apple.translation.text and surfaces an "isn't supported" alert,
            // so never probe it here — fall straight to the API/mock path.
            await MainActor.run {
                self.isModelDownloaded = false
                self.isModelInstalled = false
                self.isSessionReady = false
                self.isUsingMockTranslator = true
            }
            return
            #else
            let availability = LanguageAvailability()
            let status = await availability.status(
                from: sourceLanguage,
                to: targetLanguage
            )

            await MainActor.run {
                // .installed = model downloaded and ready (safe to use session.translate)
                // .supported = supported but needs model download (avoid — system alert on failure)
                // .unsupported = language pair not available
                self.isModelDownloaded = (status == .installed || status == .supported)
                self.isModelInstalled = (status == .installed)
                self.isSessionReady = self.sessionHolder?.isSessionReady ?? false
                // Never attempt Apple on-device translation on unsupported devices.
                // .supported triggers the system "translation not supported" alert
                // every time session.translate is called — only use it when the model is truly installed.
                self.isUsingMockTranslator = !(self.isModelInstalled && self.isSessionReady)
            }
            #endif
        }
    }

    /// Called by TranslationSessionView when the session is established.
    func sessionDidBecomeReady(_ holder: TranslationSessionHolder) {
        sessionHolder = holder
        isSessionReady = true
        downloadCount += 1
        lastDownloaded = .now
        // If we were using mock, check if real session is now available.
        if isModelInstalled {
            isUsingMockTranslator = false
        }
    }

    /// Observes download progress for the translation model.
    /// With Apple's Translation framework, models are system-managed — no progress to observe.
    func observeDownloadProgress() {
        // System-managed — no progress to observe.
    }

    /// Deletes the downloaded model to free storage.
    /// With Apple's Translation framework, models are system-managed — cannot delete individually.
    func deleteModel() {
        isModelDownloaded = false
    }

    /// Whether Apple's on-device Translation framework is safe to use.
    /// On unsupported devices (e.g. simulator where models can't be downloaded) the
    /// system shows a "translation is not supported" alert if we call it, so
    /// we only attempt it when LanguageAvailability reported .installed.
    private var canUseAppleTranslation: Bool {
        #if targetEnvironment(simulator)
        // The simulator reports pairs as "installed" but every session.translate
        // call fails with TranslationErrorDomain Code=11 AND shows a system alert.
        // Never attempt Apple on-device translation here.
        return false
        #else
        return isModelInstalled && isSessionReady && sessionHolder?.session != nil
        #endif
    }

    // MARK: - Translation

    /// Translates text from homeLanguage to targetLanguage (the direction is
    /// derived from AppSettings).
    /// Priority:
    /// 1. Cache
    /// 2. Online: Apple Translation → MyMemory → Google fallback
    /// 3. Offline: Apple Translation (on-device model) → MockTranslator (with multi-word fallback)
    ///
    /// The whole attempt is raced against a hard timeout so the UI can never
    /// spin forever (e.g. a stalled network call).
    func translate(_ text: String) async -> String {
        // Check cache first.
        if let cached = cachedTranslations[text] {
            return cached
        }

        isTranslating = true
        defer { isTranslating = false }

        let isOnline = NetworkMonitor.shared.isOnline

        if isOnline {
            // ONLINE PATH: Apple Translation → MyMemory → Google
            connectionStatus = "Online"

            // 1. Try Apple's on-device Translation framework.
            if canUseAppleTranslation, let session = sessionHolder?.session {
                do {
                    let response = try await session.translate(text)
                    let translated = response.targetText
                    cachedTranslations[text] = translated
                    isUsingMockTranslator = false
                    return translated
                } catch {
                    print("[TranslatorManager] Apple Translation failed (online): \(error.localizedDescription)")
                }
            }

            // 2. Try the network APIs, raced against a timeout.
            // Capture the codes as local constants so the @Sendable closure
            // never captures the (MainActor-isolated) manager itself.
            let fromCode = sourceLanguageCode
            let toCode = targetLanguageCode
            let apiResult = await withTimeout(seconds: 8.0) {
                await TranslationAPIService.shared.translate(text, from: fromCode, to: toCode)
            }
            if let apiResult, apiResult != text {
                cachedTranslations[text] = apiResult
                isUsingMockTranslator = false
                return apiResult
            }
        } else {
            // OFFLINE PATH: Apple Translation (on-device) → Mock with multi-word fallback
            connectionStatus = "Offline"

            // 1. Try Apple's on-device Translation (works offline if model is downloaded).
            if canUseAppleTranslation, let session = sessionHolder?.session {
                do {
                    let response = try await session.translate(text)
                    let translated = response.targetText
                    cachedTranslations[text] = translated
                    isUsingMockTranslator = false
                    return translated
                } catch {
                    print("[TranslatorManager] Apple Translation failed (offline): \(error.localizedDescription)")
                }
            }

            // 2. Try MockTranslator with multi-word fallback.
            let mockResult = translateWithMultiWordFallback(text)
            if mockResult != text {
                cachedTranslations[text] = mockResult
                isUsingMockTranslator = true
                return mockResult
            }

            isUsingMockTranslator = true
            return mockResult
        }

        // Final fallback: mock translator (online path reached here).
        isUsingMockTranslator = true
        let translated = translateWithMultiWordFallback(text)
        if translated != text {
            cachedTranslations[text] = translated
        }
        return translated
    }

    /// Runs an async operation with a hard timeout, returning the first result
    /// to arrive. If the sleep wins, the operation task is cancelled and nil is
    /// returned so the caller falls through to the next fallback. URLSession
    /// requests respond to task cancellation, so a stalled network call cannot
    /// leave the UI spinner hanging forever.
    private func withTimeout<T: Sendable>(
        seconds: TimeInterval,
        _ operation: @escaping @Sendable () async -> T
    ) async -> T? {
        await withTaskGroup(of: T?.self) { group in
            group.addTask { await operation() }
            group.addTask {
                try? await Task.sleep(for: .seconds(seconds))
                return nil
            }
            for await value in group {
                group.cancelAll()
                return value
            }
            return nil
        }
    }

    /// Mock translation with multi-word fallback:
    /// If the whole phrase isn't found, try translating each word individually and join.
    private func translateWithMultiWordFallback(_ text: String) -> String {
        let result = MockTranslator.shared.translate(text)

        // If MockTranslator returned identity and text has multiple words, try per-word.
        if result == text {
            let words = text.split(separator: " ")
            if words.count > 1 {
                var translatedWords: [String] = []
                var anyTranslated = false
                for word in words {
                    let wordStr = String(word)
                    let translatedWord = MockTranslator.shared.translate(wordStr)
                    if translatedWord != wordStr {
                        anyTranslated = true
                        translatedWords.append(translatedWord)
                    } else {
                        translatedWords.append(wordStr)
                    }
                }
                if anyTranslated {
                    return translatedWords.joined(separator: " ")
                }
            }
        }

        return result
    }

    /// Translates multiple texts concurrently.
    func translate(_ texts: [String]) async -> [String] {
        await withTaskGroup(of: (Int, String).self) { group in
            for (index, text) in texts.enumerated() {
                group.addTask {
                    let translated = await self.translate(text)
                    return (index, translated)
                }
            }

            var results = Array(repeating: "", count: texts.count)
            for await (index, translated) in group {
                results[index] = translated
            }
            return results
        }
    }

    /// Clears the in-memory translation cache.
    func clearCache() {
        cachedTranslations.removeAll()
    }
}
