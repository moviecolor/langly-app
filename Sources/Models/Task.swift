import Foundation
import SwiftData

@available(iOS 17.0, *)
@Model
final class Task {
    @Attribute(.unique) var id = UUID()
    var title: String
    var description: String?
    var isCompleted: Bool = false
    var createdAt: Date
    var updatedAt: Date
    
    init(title: String, description: String? = nil) {
        self.title = title
        self.description = description
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    func updateTitle(_ title: String) {
        self.title = title
        updatedAt = Date()
    }
    
    func updateDescription(_ description: String) {
        self.description = description
        updatedAt = Date()
    }
    
    func toggleCompletion() {
        isCompleted.toggle()
        updatedAt = Date()
    }
}