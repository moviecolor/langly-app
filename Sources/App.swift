import SwiftUI
import SwiftData

@main
struct Langly: App {
    var body: some Scene {
        WindowGroup {
            TaskListView(viewModel: TaskListViewModel(modelContainer: modelContainer))
        }
    }
    
    private var modelContainer: ModelContainer {
        do {
            return try ModelContainer(for: Task.self)
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }
}