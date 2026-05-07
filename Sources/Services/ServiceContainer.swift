//
//  ServiceContainer.swift
//  LanglyApp
//
//  Created for Langly Task Management App
//

import Foundation
import SwiftData

// MARK: - Service Container
@available(iOS 17.0, *)
final class ServiceContainer {
    static let shared = ServiceContainer()
    
    private init() {}
    
    lazy var dataPersistenceManager: DataPersistenceManager = {
        return DataPersistenceManager.shared
    }()
    
    lazy var taskRepository: TaskRepository = {
        return TaskRepositoryImpl(modelContext: dataPersistenceManager.makeContext())
    }()
    
    lazy var categoryRepository: CategoryRepository = {
        return CategoryRepositoryImpl(modelContext: dataPersistenceManager.makeContext())
    }()
    
    lazy var themeRepository: ThemeRepository = {
        return ThemeRepositoryImpl(modelContext: dataPersistenceManager.makeContext())
    }()
    
    lazy var settingsService: SettingsService = {
        return SettingsServiceImpl(modelContext: dataPersistenceManager.makeContext())
    }()
    
    // MARK: - ViewModels
    func makeTaskListViewModel() -> TaskListViewModel {
        return TaskListViewModel(
            modelContainer: dataPersistenceManager.modelContainer
        )
    }
    
    func makeSettingsViewModel() -> SettingsViewModel {
        return SettingsViewModel(settingsService: settingsService)
    }
}