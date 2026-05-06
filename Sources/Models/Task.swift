//
//  Task.swift
//  LanglyApp
//
//  Created for Langly Task Management App
//

import Foundation
import SwiftData

@available(iOS 17.0, *)
@Model
final class Task {
    @Attribute(.unique) var id = UUID()
    var title: String
    var description: String?
    var category: Category?
    var dueDate: Date?
    var isCompleted: Bool = false
    var theme: Theme?
    var createdAt: Date
    var updatedAt: Date
    
    init(title: String, description: String? = nil, category: Category? = nil, dueDate: Date? = nil, theme: Theme? = nil) {
        self.title = title
        self.description = description
        self.category = category
        self.dueDate = dueDate
        self.theme = theme
        self.createdAt = Date()
        self.updatedAt = Date()
        self.id = UUID()
    }
    
    // Default initializer for SwiftData
    init() {
        self.title = ""
        self.description = nil
        self.category = nil
        self.dueDate = nil
        self.isCompleted = false
        self.theme = nil
        self.createdAt = Date()
        self.updatedAt = Date()
        self.id = UUID()
    }
    
    func updateTitle(_ title: String) {
        self.title = title
        self.updatedAt = Date()
    }
    
    func updateDescription(_ description: String) {
        self.description = description
        self.updatedAt = Date()
    }
    
    func toggleCompletion() {
        self.isCompleted.toggle()
        self.updatedAt = Date()
    }
}