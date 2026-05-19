import SwiftUI
import SwiftData

@main
struct Langly: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
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
                     WordBlock.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
