//
//  TaskRepository.swift
//  LanglyApp
//
//  Created for Langly Task Management App
//

import Foundation
import SwiftData

protocol TaskRepository {
    func createTask(_ task: Task) async throws
    func getTask(id: UUID) async throws -> Task?
    func updateTask(_ task: Task) async throws
    func deleteTask(id: UUID) async throws
    func getAllTasks() async throws -> [Task]
    func getCompletedTasks() async throws -> [Task]
    func getPendingTasks() async throws -> [Task]
    func getOverdueTasks() async throws -> [Task]
    func searchTasks(query: String) async throws -> [Task]
}

@available(iOS 17.0, *)
final class TaskRepositoryImpl: TaskRepository {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func createTask(_ task: Task) async throws {
        try await Task.sleep(nanoseconds: 1_000_000) // Small delay for demonstration
        modelContext.insert(task)
        try await saveContext()
    }
    
    func getTask(id: UUID) async throws -> Task? {
        try await modelContext.fetch(
            FetchDescriptor<Task, UUID>(predicate: #Predicate<Task> { task in
                task.id == id
            })
        ).first
    }
    
    func updateTask(_ task: Task) async throws {
        try await Task.sleep(nanoseconds: 1_000_000) // Small delay for demonstration
        try await saveContext()
    }
    
    func deleteTask(id: UUID) async throws {
        try await Task.sleep(nanoseconds: 1_000_000) // Small delay for demonstration
        guard let task = try await getTask(id: id) else {
            throw RepositoryError.taskNotFound
        }
        modelContext.delete(task)
        try await saveContext()
    }
    
    func getAllTasks() async throws -> [Task] {
        try await modelContext.fetch(
            FetchDescriptor<Task>(sortBy: [SortDescriptor(\Task.createdAt, order: .reverse)])
        )
    }
    
    func getCompletedTasks() async throws -> [Task] {
        try await modelContext.fetch(
            FetchDescriptor<Task, Bool>(predicate: #Predicate<Task> { task in
                task.isCompleted == true
            }, sortBy: [SortDescriptor(\Task.updatedAt, order: .reverse)])
        )
    }
    
    func getPendingTasks() async throws -> [Task] {
        try await modelContext.fetch(
            FetchDescriptor<Task, Bool>(predicate: #Predicate<Task> { task in
                task.isCompleted == false
            }, sortBy: [SortDescriptor(\Task.updatedAt, order: .reverse)])
        )
    }
    
    func getOverdueTasks() async throws -> [Task] {
        try await modelContext.fetch(
            FetchDescriptor<Task, Date>(predicate: #Predicate<Task> { task in
                task.isCompleted == false && task.dueDate != nil && task.dueDate! < Date()
            }, sortBy: [SortDescriptor(\Task.dueDate, order: .ascending)])
        )
    }
    
    func searchTasks(query: String) async throws -> [Task] {
        try await modelContext.fetch(
            FetchDescriptor<Task, String>(predicate: #Predicate<Task> { task in
                task.title.localizedCaseInsensitiveContains(query) || 
                (task.description?.localizedCaseInsensitiveContains(query) ?? false)
            }, sortBy: [SortDescriptor(\Task.updatedAt, order: .reverse)])
        )
    }
    
    // Helper to save context
    private func saveContext() async throws {
        try await modelContext.save()
    }
}

// MARK: - Error Handling
enum RepositoryError: Error, LocalizedError {
    case taskNotFound
    case categoryNotFound
    case themeNotFound
    case invalidData
    case persistenceError
    
    var errorDescription: String? {
        switch self {
        case .taskNotFound:
            return "Task not found"
        case .categoryNotFound:
            return "Category not found"
        case .themeNotFound:
            return "Theme not found"
        case .invalidData:
            return "Invalid data provided"
        case .persistenceError:
            return "Persistence error occurred"
        }
    }
}