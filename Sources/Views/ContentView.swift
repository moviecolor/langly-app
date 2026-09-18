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
            #if !targetEnvironment(simulator)
            // On-device only: the simulator structurally cannot use Apple's
            // on-device Translation framework, and mounting the session there
            // triggers the system "translation is not supported" alert.
            TranslationSessionView(
                holder: sessionHolder,
                source: translatorManager.sourceLanguage,
                target: translatorManager.targetLanguage
            )
            .onAppear {
                translatorManager.sessionDidBecomeReady(sessionHolder)
            }
            #endif
        }
        .task {
            // Local, deterministic seeding FIRST — never gate local data behind
            // a StoreKit network query. `restorePurchases()` (below) can hang
            // for 10+ seconds on the simulator when the App Store is slow, and
            // would otherwise delay first-launch vocabulary seeding.
            seedStarterVocabulary()
            seedStreakTracker()
            seedAnalytics()

            // Premium entitlement refresh is already kicked off in
            // IAPManager.init(); this second nudge is fire-and-forget so it can
            // never block the launch task.
            Task { await iapManager.restorePurchases() }

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
