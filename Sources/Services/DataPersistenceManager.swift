//
//  DataPersistenceManager.swift
//  LanglyApp
//
//  Created for Langly Task Management App
//

import Foundation
import SwiftData

@available(iOS 17.0, *)
final class DataPersistenceManager {
    static let shared = DataPersistenceManager()
    
    private init() {}
    
    // The model container for all data entities
    lazy var modelContainer: ModelContainer = {
        do {
            return try ModelContainer(for: Task.self, Category.self, Theme.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
    
    // Create a new model context for data operations
    func makeContext() -> ModelContext {
        return ModelContext(modelContainer: modelContainer)
    }
    
    // Save changes to persistent store
    func saveContext(_ context: ModelContext) throws {
        try context.save()
    }
    
    // Handle data migration if needed
    func handleMigration() {
        // Implementation for handling schema migrations
        // This would be more complex in a real application
    }
    
    // Clear all data (for testing purposes)
    func clearAllData() {
        do {
            let context = makeContext()
            let tasks = try context.fetch(FetchDescriptor<Task>())
            let categories = try context.fetch(FetchDescriptor<Category>())
            let themes = try context.fetch(FetchDescriptor<Theme>())
            
            for task in tasks {
                context.delete(task)
            }
            for category in categories {
                context.delete(category)
            }
            for theme in themes {
                context.delete(theme)
            }
            
            try saveContext(context)
        } catch {
            print("Failed to clear data: \(error)")
        }
    }
}