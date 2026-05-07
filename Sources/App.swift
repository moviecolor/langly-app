import SwiftUI
import SwiftData

@main
struct Langly: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                TaskListView(viewModel: TaskListViewModel(modelContainer: modelContainer))
                    .navigationDestination(for: String.self) { setting in
                        if setting == "settings" {
                            SettingsView(viewModel: ServiceContainer.shared.makeSettingsViewModel())
                        }
                    }
            }
        }
    }
    
    private var modelContainer: ModelContainer {
        do {
            return try ModelContainer(for: Task.self, Category.self, Theme.self, Settings.self)
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }
}