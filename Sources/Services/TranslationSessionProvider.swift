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
struct TranslationSessionView: View {
    let holder: TranslationSessionHolder
    let source: Locale.Language
    let target: Locale.Language

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .translationTask(source: source, target: target) { session in
                holder.session = session
                holder.isSessionReady = true
                holder.sourceLanguage = source
                holder.targetLanguage = target
            }
    }
}
