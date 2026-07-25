import SwiftUI
import SwiftData

@main
struct Langly: App {
     @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
          }
          .modelContainer(modelContainer)
      }

    private var modelContainer: ModelContainer {
        do {
            return try ModelContainer(
                for: AppSettings.self,
                     VocabularyWord.self,
                     SentenceGroup.self,
                     Sentence.self,
                     QASession.self,
                     ModuleProgress.self,
                     WordBlock.self,
                     StreakTracker.self,
                     LocalAnalytics.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
