import Foundation
import SwiftData

/// Tracks mastery progress for a specific module.
@Model
final class ModuleProgress {
    var moduleName: String
    var masteredItems: Set<String>
    var learningItems: Set<String>
    var unlearnedItems: Set<String>
    var lastUpdated: Date

    init(
        moduleName: String,
        masteredItems: Set<String> = [],
        learningItems: Set<String> = [],
        unlearnedItems: Set<String> = [],
        lastUpdated: Date = .now
    ) {
        self.moduleName = moduleName
        self.masteredItems = masteredItems
        self.learningItems = learningItems
        self.unlearnedItems = unlearnedItems
        self.lastUpdated = lastUpdated
    }
}
