//
//  Task+Extensions.swift
//  LanglyApp
//
//  Created for Langly Task Management App
//

import Foundation
import SwiftData

// MARK: - Task Extensions
extension Task {
    // Update task with new values, only updating non-nil values
    func update(with title: String? = nil, description: String? = nil, category: Category? = nil, dueDate: Date? = nil, theme: Theme? = nil, isCompleted: Bool? = nil) {
        if let title = title {
            self.title = title
        }
        if let description = description {
            self.description = description
        }
        if let category = category {
            self.category = category
        }
        if let dueDate = dueDate {
            self.dueDate = dueDate
        }
        if let theme = theme {
            self.theme = theme
        }
        if let isCompleted = isCompleted {
            self.isCompleted = isCompleted
        }
        self.updatedAt = Date()
    }
    
    // Toggle completion status and update timestamp
    func toggleCompletion() {
        self.isCompleted.toggle()
        self.updatedAt = Date()
    }
    
    // Check if task is overdue
    var isOverdue: Bool {
        guard let dueDate = self.dueDate, !self.isCompleted else {
            return false
        }
        return dueDate < Date()
    }
    
    // Get task status string
    var status: String {
        if isCompleted {
            return "Completed"
        } else if isOverdue {
            return "Overdue"
        } else {
            return "Pending"
        }
    }
}