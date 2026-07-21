import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var iapManager = IAPManager()
    @StateObject private var translatorManager = TranslatorManager()
    @State private var showLaunch = true
    @State private var sessionHolder = TranslationSessionHolder()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            MainMenuView()
        }
        .ignoresSafeArea()
        .fullScreenCover(isPresented: $showLaunch) {
            LaunchScreen()
        }
        .environmentObject(iapManager)
        .environmentObject(translatorManager)
        .overlay {
            TranslationSessionView(
                holder: sessionHolder,
                source: translatorManager.sourceLanguage,
                target: translatorManager.targetLanguage
            )
            .onAppear {
                translatorManager.sessionDidBecomeReady(sessionHolder)
            }
        }
        .task {
            await iapManager.restorePurchases()
            seedStarterVocabulary()
        }
    }

    /// Seeds a "Starter Vocabulary" block with 15 common words on first launch.
    private func seedStarterVocabulary() {
        // Check if any blocks already exist — skip if so.
        let descriptor = FetchDescriptor<WordBlock>()
        guard let count = try? modelContext.fetchCount(descriptor), count == 0 else { return }

        let starterWords: [(native: String, translated: String)] = [
            ("yes", "sim"),
            ("no", "não"),
            ("great", "ótimo"),
            ("always", "sempre"),
            ("help", "ajuda"),
            ("sometimes", "às vezes"),
            ("who", "quem"),
            ("where", "onde"),
            ("what", "o que"),
            ("when", "quando"),
            ("why", "por quê"),
            ("today", "hoje"),
            ("tomorrow", "amanhã"),
            ("he", "ele"),
            ("she", "ela"),
        ]

        let block = WordBlock(blockName: "Starter Vocabulary", vocabularyWords: [], isActive: true)
        modelContext.insert(block)

        for (index, pair) in starterWords.enumerated() {
            let word = VocabularyWord(
                nativeWord: pair.native,
                translatedWord: pair.translated,
                masteryLevel: .unlearned,
                wordBlockIndex: index,
                dateAdded: .now
            )
            modelContext.insert(word)
            block.vocabularyWords.append(word)
        }

        try? modelContext.save()
    }
}

#Preview {
    ContentView()
}
