import Foundation
import SwiftData

@MainActor
class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var isLoading = false
    
    private let modelContext: ModelContext
    private let modelContainer: ModelContainer
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = modelContainer.mainContext
        loadTasks()
    }
    
    private func loadTasks() {
        do {
            isLoading = true
            let descriptor = FetchDescriptor<Task>()
            tasks = try modelContext.fetch(descriptor)
            isLoading = false
        } catch {
            print("Failed to load tasks: \(error)")
            isLoading = false
        }
    }
    
    func addTask(title: String, description: String? = nil) {
        let newTask = Task(title: title, description: description)
        tasks.append(newTask)
        saveTask(newTask)
    }
    
    func updateTask(_ task: Task, title: String? = nil, description: String? = nil, isCompleted: Bool? = nil) {
        if let title = title {
            task.title = title
        }
        if let description = description {
            task.description = description
        }
        if let isCompleted = isCompleted {
            task.isCompleted = isCompleted
        }
        saveTask(task)
    }
    
    func deleteTask(_ task: Task) {
        modelContext.delete(task)
        tasks.removeAll { $0.id == task.id }
        try? modelContext.save()
    }
    
    private func saveTask(_ task: Task) {
        do {
            try modelContext.save()
            loadTasks()
        } catch {
            print("Failed to save task: \(error)")
        }
    }
}