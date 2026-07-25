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
            seedStreakTracker()
            seedAnalytics()
            // Request notification permission and schedule daily reminder.
            let granted = await NotificationManager.shared.requestPermission()
            if granted {
                NotificationManager.shared.scheduleDailyReminder(hour: 19, minute: 0)
            }
        }
    }

    /// Seeds themed vocabulary blocks on first launch.
    private func seedStarterVocabulary() {
        // Check if any blocks already exist — skip if so.
        let descriptor = FetchDescriptor<WordBlock>()
        guard let count = try? modelContext.fetchCount(descriptor), count == 0 else { return }

        for blockContent in VocabularyContent.starterBlocks {
            let block = WordBlock(blockName: blockContent.name, vocabularyWords: [], isActive: true)
            modelContext.insert(block)

            for (index, pair) in blockContent.words.enumerated() {
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
        }

        try? modelContext.save()
    }

    /// Seeds a StreakTracker if none exists.
    private func seedStreakTracker() {
        let descriptor = FetchDescriptor<StreakTracker>()
        guard let count = try? modelContext.fetchCount(descriptor), count == 0 else { return }
        let tracker = StreakTracker()
        modelContext.insert(tracker)
        try? modelContext.save()
    }

    /// Seeds LocalAnalytics if none exists.
    private func seedAnalytics() {
        let descriptor = FetchDescriptor<LocalAnalytics>()
        guard let count = try? modelContext.fetchCount(descriptor), count == 0 else { return }
        let analytics = LocalAnalytics()
        modelContext.insert(analytics)
        try? modelContext.save()
    }
}

#Preview {
    ContentView()
}
