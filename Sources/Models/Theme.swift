//
//  Theme.swift
//  LanglyApp
//
//  Created for Langly Task Management App
//

import Foundation
import SwiftData

@available(iOS 17.0, *)
@Model
final class Theme {
    @Attribute(.unique) var id = UUID()
    var name: String
    var primaryColor: String
    var secondaryColor: String
    var accentColor: String
    
    init(name: String, primaryColor: String, secondaryColor: String, accentColor: String) {
        self.name = name
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.accentColor = accentColor
        self.id = UUID()
    }
    
    // Default initializer for SwiftData
    init() {
        self.name = ""
        self.primaryColor = ""
        self.secondaryColor = ""
        self.accentColor = ""
        self.id = UUID()
    }
}