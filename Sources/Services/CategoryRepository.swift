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
        // SwiftData handles updates automatically with the same object reference
    }
    
    func deleteCategory(id: UUID) async throws {
        try await Task.sleep(nanoseconds: 1_000_000) // Small delay for demonstration
        guard let category = try await getCategory(id: id) else {
            throw RepositoryError.categoryNotFound
        }
        modelContext.delete(category)
    }
    
    func getAllCategories() async throws -> [Category] {
        try await modelContext.fetch(
            FetchDescriptor<Category>()
        )
    }
}