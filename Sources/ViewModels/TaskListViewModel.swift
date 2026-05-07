import Foundation
import SwiftData
import Combine

@MainActor
class TaskListViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let modelContext: ModelContext
    private let modelContainer: ModelContainer
    private var cancellables = Set<AnyCancellable>()
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = modelContainer.mainContext
        loadTasks()
    }
    
    private func loadTasks() {
        do {
            isLoading = true
            error = nil
            let descriptor = FetchDescriptor<Task>(sortBy: [SortDescriptor(\Task.createdAt, order: .reverse)])
            tasks = try modelContext.fetch(descriptor)
            isLoading = false
        } catch {
            print("Failed to load tasks: \(error)")
            error = error.localizedDescription
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
        task.updatedAt = Date()
        saveTask(task)
    }
    
    func deleteTask(_ task: Task) {
        modelContext.delete(task)
        tasks.removeAll { $0.id == task.id }
        try? modelContext.save()
    }
    
    func toggleTaskCompletion(_ task: Task) {
        task.toggleCompletion()
        saveTask(task)
    }
    
    func clearCompletedTasks() {
        let completedTasks = tasks.filter { $0.isCompleted }
        for task in completedTasks {
            modelContext.delete(task)
        }
        tasks.removeAll { $0.isCompleted }
        try? modelContext.save()
    }
    
    func searchTasks(query: String) {
        Task {
            do {
                isLoading = true
                error = nil
                let descriptor = FetchDescriptor<Task>(
                    predicate: #Predicate<Task> { task in
                        task.title.localizedCaseInsensitiveContains(query) || 
                        (task.description?.localizedCaseInsensitiveContains(query) ?? false)
                    },
                    sortBy: [SortDescriptor(\Task.updatedAt, order: .reverse)]
                )
                tasks = try modelContext.fetch(descriptor)
                isLoading = false
            } catch {
                print("Failed to search tasks: \(error)")
                error = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    private func saveTask(_ task: Task) {
        Task {
            do {
                try modelContext.save()
            } catch {
                print("Failed to save task: \(error)")
                error = error.localizedDescription
            }
        }
    }
}