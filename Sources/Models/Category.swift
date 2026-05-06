//
//  Category.swift
//  LanglyApp
//
//  Created for Langly Task Management App
//

import Foundation
import SwiftData

@available(iOS 17.0, *)
@Model
final class Category {
    @Attribute(.unique) var id = UUID()
    var name: String
    var color: String
    var icon: String
    
    init(name: String, color: String, icon: String) {
        self.name = name
        self.color = color
        self.icon = icon
        self.id = UUID()
    }
    
    // Default initializer for SwiftData
    init() {
        self.name = ""
        self.color = ""
        self.icon = ""
        self.id = UUID()
    }
}