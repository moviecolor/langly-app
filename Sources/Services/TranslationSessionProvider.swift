import SwiftUI
@preconcurrency import Translation

/// A shared, @Observable holder for the TranslationSession.
/// The session is captured via a hidden SwiftUI view's .translationTask modifier
/// and made available to non-View code (e.g., TranslatorManager).
@Observable
final class TranslationSessionHolder {
    var session: TranslationSession?
    var isSessionReady: Bool = false
    var sourceLanguage: Locale.Language?
    var targetLanguage: Locale.Language?
}

/// A hidden view that establishes a TranslationSession for the app.
/// Place this once in the view hierarchy (e.g., in ContentView).
/// The zero-size clear view ensures it has no visual impact.
///
/// Performs a preflight LanguageAvailability check first so the system
/// "translation is not supported" alert never appears on unsupported
/// devices (simulator, older hardware, etc.).
struct TranslationSessionView: View {
    let holder: TranslationSessionHolder
    let source: Locale.Language
    let target: Locale.Language

    /// Whether the language pair is actually ready for on-device translation.
    @State private var isAvailable: Bool?

    var body: some View {
        Group {
            if isAvailable == true {
                Color.clear
                    .frame(width: 0, height: 0)
                    .translationTask(source: source, target: target) { session in
                        holder.session = session
                        holder.isSessionReady = true
                        holder.sourceLanguage = source
                        holder.targetLanguage = target
                    }
            } else {
                Color.clear.frame(width: 0, height: 0)
            }
        }
        .task {
            // On the simulator, Apple's on-device Translation framework is
            // structurally unavailable — mounting translationTask there always
            // triggers the system "translation is not supported" alert.
            // Skip entirely; TranslatorManager falls back to MyMemory/mock.
            #if targetEnvironment(simulator)
            isAvailable = false
            return
            #else
            // On device, only mount the translationTask when the system confirms
            // the model is actually installed (.installed) — NOT merely .supported.
            let availability = LanguageAvailability()
            let status = await availability.status(from: source, to: target)
            isAvailable = (status == .installed)
            #endif
        }
    }
}
