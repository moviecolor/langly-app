//
//  CategoryRepository.swift
//  LanglyApp
//
//  Created for Langly Task Management App
//

import Foundation
import SwiftData

protocol CategoryRepository {
    func createCategory(_ category: Category) async throws
    func getCategory(id: UUID) async throws -> Category?
    func updateCategory(_ category: Category) async throws
    func deleteCategory(id: UUID) async throws
    func getAllCategories() async throws -> [Category]
    func getCategoryByName(name: String) async throws -> Category?
}

@available(iOS 17.0, *)
final class CategoryRepositoryImpl: CategoryRepository {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func createCategory(_ category: Category) async throws {
        try await Task.sleep(nanoseconds: 1_000_000) // Small delay for demonstration
        modelContext.insert(category)
        try await saveContext()
    }
    
    func getCategory(id: UUID) async throws -> Category? {
        try await modelContext.fetch(
            FetchDescriptor<Category, UUID>(predicate: #Predicate<Category> { category in
                category.id == id
            })
        ).first
    }
    
    func updateCategory(_ category: Category) async throws {
        try await Task.sleep(nanoseconds: 1_000_000) // Small delay for demonstration
        try await saveContext()
    }
    
    func deleteCategory(id: UUID) async throws {
        try await Task.sleep(nanoseconds: 1_000_000) // Small delay for demonstration
        guard let category = try await getCategory(id: id) else {
            throw RepositoryError.categoryNotFound
        }
        modelContext.delete(category)
        try await saveContext()
    }
    
    func getAllCategories() async throws -> [Category] {
        try await modelContext.fetch(
            FetchDescriptor<Category>(sortBy: [SortDescriptor(\Category.name, order: .ascending)])
        )
    }
    
    func getCategoryByName(name: String) async throws -> Category? {
        try await modelContext.fetch(
            FetchDescriptor<Category, String>(predicate: #Predicate<Category> { category in
                category.name == name
            })
        ).first
    }
    
    // Helper to save context
    private func saveContext() async throws {
        try await modelContext.save()
    }
}