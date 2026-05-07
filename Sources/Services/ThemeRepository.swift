//
//  ThemeRepository.swift
//  LanglyApp
//
//  Created for Langly Task Management App
//

import Foundation
import SwiftData

protocol ThemeRepository {
    func createTheme(_ theme: Theme) async throws
    func getTheme(id: UUID) async throws -> Theme?
    func updateTheme(_ theme: Theme) async throws
    func deleteTheme(id: UUID) async throws
    func getAllThemes() async throws -> [Theme]
    func getThemeByName(name: String) async throws -> Theme?
}

@available(iOS 17.0, *)
final class ThemeRepositoryImpl: ThemeRepository {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func createTheme(_ theme: Theme) async throws {
        try await Task.sleep(nanoseconds: 1_000_000) // Small delay for demonstration
        modelContext.insert(theme)
        try await saveContext()
    }
    
    func getTheme(id: UUID) async throws -> Theme? {
        try await modelContext.fetch(
            FetchDescriptor<Theme, UUID>(predicate: #Predicate<Theme> { theme in
                theme.id == id
            })
        ).first
    }
    
    func updateTheme(_ theme: Theme) async throws {
        try await Task.sleep(nanoseconds: 1_000_000) // Small delay for demonstration
        try await saveContext()
    }
    
    func deleteTheme(id: UUID) async throws {
        try await Task.sleep(nanoseconds: 1_000_000) // Small delay for demonstration
        guard let theme = try await getTheme(id: id) else {
            throw RepositoryError.themeNotFound
        }
        modelContext.delete(theme)
        try await saveContext()
    }
    
    func getAllThemes() async throws -> [Theme] {
        try await modelContext.fetch(
            FetchDescriptor<Theme>(sortBy: [SortDescriptor(\Theme.name, order: .ascending)])
        )
    }
    
    func getThemeByName(name: String) async throws -> Theme? {
        try await modelContext.fetch(
            FetchDescriptor<Theme, String>(predicate: #Predicate<Theme> { theme in
                theme.name == name
            })
        ).first
    }
    
    // Helper to save context
    private func saveContext() async throws {
        try await modelContext.save()
    }
}