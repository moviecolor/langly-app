import Foundation
import SwiftData

class TaskService {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func saveTask(_ task: Task) {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save task: \(error)")
        }
    }
    
    func fetchTasks() -> [Task] {
        do {
            let descriptor = FetchDescriptor<Task>(sortBy: [SortDescriptor(\Task.createdAt, order: .reverse)])
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch tasks: \(error)")
            return []
        }
    }
    
    func deleteTask(_ task: Task) {
        modelContext.delete(task)
        try? modelContext.save()
    }
}