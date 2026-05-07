//
//  HomeScreenViewModel.swift
//  LanglyApp
//
//  Created for Langly Task Management App
//

import Foundation
import SwiftUI
import Combine

@available(iOS 17.0, *)
@MainActor
final class HomeScreenViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let taskRepository: TaskRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(taskRepository: TaskRepository) {
        self.taskRepository = taskRepository
        loadTasks()
    }
    
    func loadTasks() {
        Task {
            do {
                isLoading = true
                errorMessage = nil
                tasks = try await taskRepository.getAllTasks()
                isLoading = false
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func addTask(title: String, description: String? = nil, category: Category? = nil, dueDate: Date? = nil) {
        Task {
            do {
                let newTask = Task(title: title, description: description, category: category, dueDate: dueDate)
                try await taskRepository.createTask(newTask)
                // Refresh the task list
                await loadTasks()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func toggleTaskCompletion(_ task: Task) {
        Task {
            do {
                try await taskRepository.updateTask(task)
                // Refresh the task list
                await loadTasks()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func deleteTask(_ task: Task) {
        Task {
            do {
                try await taskRepository.deleteTask(id: task.id)
                // Refresh the task list
                await loadTasks()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func searchTasks(query: String) {
        // Search implementation would go here
    }
}

// MARK: - Data loading extension
extension HomeScreenViewModel {
    func loadPendingTasks() {
        Task {
            do {
                isLoading = true
                errorMessage = nil
                tasks = try await taskRepository.getPendingTasks()
                isLoading = false
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func loadCompletedTasks() {
        Task {
            do {
                isLoading = true
                errorMessage = nil
                tasks = try await taskRepository.getCompletedTasks()
                isLoading = false
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
}