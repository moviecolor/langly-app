//
//  SettingsService.swift
//  LanglyApp
//
//  Created for Langly Task Management App
//

import Foundation
import SwiftData

@available(iOS 17.0, *)
protocol SettingsService {
    func getAppIcon() async throws -> String
    func setAppIcon(_ icon: String) async throws
    func getTheme() async throws -> String
    func setTheme(_ theme: String) async throws
    func getLanguage() async throws -> String
    func setLanguage(_ language: String) async throws
}

@available(iOS 17.0, *)
final class SettingsServiceImpl: SettingsService {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func getAppIcon() async throws -> String {
        // For simplicity, we'll use a basic settings approach
        // In a real app, this would fetch a Theme entity or similar from the database
        // This could either be part of a Settings entity or be stored in UserDefaults
        let settings = try await fetchOrCreateSettings()
        return settings.appIcon ?? "app_icon_default"
    }
    
    func setAppIcon(_ icon: String) async throws {
        let settings = try await fetchOrCreateSettings()
        settings.appIcon = icon
        try await saveContext()
    }
    
    func getTheme() async throws -> String {
        let settings = try await fetchOrCreateSettings()
        return settings.theme ?? "light"
    }
    
    func setTheme(_ theme: String) async throws {
        let settings = try await fetchOrCreateSettings()
        settings.theme = theme
        try await saveContext()
    }
    
    func getLanguage() async throws -> String {
        let settings = try await fetchOrCreateSettings()
        return settings.language ?? "en"
    }
    
    func setLanguage(_ language: String) async throws {
        let settings = try await fetchOrCreateSettings()
        settings.language = language
        try await saveContext()
    }
    
    // Helper to fetch or create settings
    private func fetchOrCreateSettings() async throws -> Settings {
        let fetchDescriptor = FetchDescriptor<Settings>()
        let existingSettings = try await modelContext.fetch(fetchDescriptor)
        
        if let settings = existingSettings.first {
            return settings
        } else {
            let newSettings = Settings()
            modelContext.insert(newSettings)
            return newSettings
        }
    }
    
    // Helper to save context
    private func saveContext() async throws {
        try await modelContext.save()
    }
}

// MARK: - Settings Model
@available(iOS 17.0, *)
@Model
final class Settings {
    @Attribute(.unique)
    var id: UUID
    
    var appIcon: String?
    var theme: String?
    var language: String?
    var notificationsEnabled: Bool = true
    var darkMode: Bool = false
    
    init() {
        self.id = UUID()
    }
}