import Foundation
import SwiftData

/// A question-and-answer pair for the Q&A module, stored in both English and Portuguese.
@Model
final class QASession {
    var englishQ: String
    var portugueseQ: String
    var englishA: String
    var portugueseA: String
    var masteryLevel: MasteryLevel
    var dateAdded: Date

    init(
        englishQ: String,
        portugueseQ: String = "",
        englishA: String,
        portugueseA: String = "",
        masteryLevel: MasteryLevel = .unlearned,
        dateAdded: Date = .now
    ) {
        self.englishQ = englishQ
        self.portugueseQ = portugueseQ
        self.englishA = englishA
        self.portugueseA = portugueseA
        self.masteryLevel = masteryLevel
        self.dateAdded = dateAdded
    }
}
