import Foundation
import SwiftData

/// A single sentence with its English source and translated target-language version.
@Model
final class Sentence {
    var english: String
    var translation: String
    var masteryLevel: MasteryLevel
    var lastPracticed: Date?
    var groupIndex: Int

    init(
        english: String,
        translation: String = "",
        masteryLevel: MasteryLevel = .unlearned,
        lastPracticed: Date? = nil,
        groupIndex: Int = 0
    ) {
        self.english = english
        self.translation = translation
        self.masteryLevel = masteryLevel
        self.lastPracticed = lastPracticed
        self.groupIndex = groupIndex
    }
}
