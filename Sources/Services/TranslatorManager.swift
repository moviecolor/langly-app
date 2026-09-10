import Foundation
import SwiftUI
@preconcurrency import Translation

/// Manages on-device translation using Apple's native Translation framework.
/// Targets Portuguese (Brazil) as the default target language.
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

    @Published var isModelDownloaded: Bool = false
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

    let sourceLanguage = Locale.Language(identifier: "en")
    let targetLanguage = Locale.Language(identifier: "pt")

    // MARK: - Initialization

    init() {
        checkModelStatus()
        // Start network monitoring on first use.
        NetworkMonitor.shared.start()
    }

    // MARK: - Model Management

    /// Checks whether translation between source and target languages is available.
    /// With Apple's Translation framework, models are managed by the system.
    func checkModelStatus() {
        Task {
            let availability = LanguageAvailability()
            let status = await availability.status(
                from: sourceLanguage,
                to: targetLanguage
            )

            await MainActor.run {
                // .installed = model downloaded and ready
                // .supported = supported but needs model download
                // .unsupported = language pair not available
                self.isModelDownloaded = (status == .installed || status == .supported)
                self.isSessionReady = self.sessionHolder?.isSessionReady ?? false
                self.isUsingMockTranslator = !(self.isModelDownloaded && self.isSessionReady)
            }
        }
    }

    /// Called by TranslationSessionView when the session is established.
    func sessionDidBecomeReady(_ holder: TranslationSessionHolder) {
        sessionHolder = holder
        isSessionReady = true
        downloadCount += 1
        lastDownloaded = .now
        // If we were using mock, check if real session is now available.
        if isModelDownloaded {
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

    // MARK: - Translation

    /// Translates text from English to Portuguese.
    /// Priority:
    /// 1. Cache
    /// 2. Online: Apple Translation → MyMemory → Google fallback
    /// 3. Offline: Apple Translation (on-device model) → MockTranslator (with multi-word fallback)
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
            if let session = sessionHolder?.session {
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

            // 2. Try MyMemory free API.
            let apiResult = await TranslationAPIService.shared.translate(text, from: "en", to: "pt")
            if apiResult != text {
                cachedTranslations[text] = apiResult
                isUsingMockTranslator = false
                return apiResult
            }
        } else {
            // OFFLINE PATH: Apple Translation (on-device) → Mock with multi-word fallback
            connectionStatus = "Offline"

            // 1. Try Apple's on-device Translation (works offline if model is downloaded).
            if let session = sessionHolder?.session {
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
