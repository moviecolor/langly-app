//
//  SettingsViewModel.swift
//  LanglyApp
//
//  Created for Langly Task Management App
//

import Foundation
import SwiftUI

@available(iOS 17.0, *)
@MainActor
class SettingsViewModel: ObservableObject {
    @Published var appIcon: String = "app_icon_default"
    @Published var selectedTheme: String = "light"
    @Published var selectedLanguage: String = "en"
    @Published var notificationsEnabled: Bool = true
    @Published var darkMode: Bool = false
    
    private let settingsService: SettingsService
    private var cancellables = Set<AnyCancellable>()
    
    init(settingsService: SettingsService) {
        self.settingsService = settingsService
        loadSettings()
    }
    
    func loadSettings() {
        Task {
            do {
                // Load app icon
                self.appIcon = try await settingsService.getAppIcon()
                
                // Load theme
                self.selectedTheme = try await settingsService.getTheme()
                
                // Load language
                self.selectedLanguage = try await settingsService.getLanguage()
                
                // In a real app, these would be loaded from the service
                // For now, we'll keep defaults
            } catch {
                print("Error loading settings: \(error)")
            }
        }
    }
    
    func saveSettings() {
        Task {
            do {
                // Save app icon
                try await settingsService.setAppIcon(appIcon)
                
                // Save theme
                try await settingsService.setTheme(selectedTheme)
                
                // Save language
                try await settingsService.setLanguage(selectedLanguage)
                
                // In a real app, save other settings as well
            } catch {
                print("Error saving settings: \(error)")
            }
        }
    }
    
    func resetToDefaultSettings() {
        appIcon = "app_icon_default"
        selectedTheme = "light"
        selectedLanguage = "en"
        notificationsEnabled = true
        darkMode = false
        saveSettings()
    }
    
    func changeAppIcon(to icon: String) {
        appIcon = icon
        Task {
            do {
                try await settingsService.setAppIcon(icon)
            } catch {
                print("Error changing app icon: \(error)")
            }
        }
    }
    
    func changeTheme(to theme: String) {
        selectedTheme = theme
        Task {
            do {
                try await settingsService.setTheme(theme)
            } catch {
                print("Error changing theme: \(error)")
            }
        }
    }
}