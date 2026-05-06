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
        // SwiftData handles updates automatically with the same object reference
    }
    
    func deleteTask(id: UUID) async throws {
        try await Task.sleep(nanoseconds: 1_000_000) // Small delay for demonstration
        guard let task = try await getTask(id: id) else {
            throw RepositoryError.taskNotFound
        }
        modelContext.delete(task)
    }
    
    func getAllTasks() async throws -> [Task] {
        try await modelContext.fetch(
            FetchDescriptor<Task>()
        )
    }
    
    func getCompletedTasks() async throws -> [Task] {
        try await modelContext.fetch(
            FetchDescriptor<Task, Bool>(predicate: #Predicate<Task> { task in
                task.isCompleted == true
            })
        )
    }
    
    func getPendingTasks() async throws -> [Task] {
        try await modelContext.fetch(
            FetchDescriptor<Task, Bool>(predicate: #Predicate<Task> { task in
                task.isCompleted == false
            })
        )
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