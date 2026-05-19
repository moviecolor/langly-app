import Foundation
import SwiftData

/// Mastery progression for vocabulary words.
enum MasteryLevel: String, Codable, CaseIterable {
    case unlearned
    case learning
    case mastered
}

/// A single vocabulary word pair (native language ↔ target language).
@Model
final class VocabularyWord {
    var nativeWord: String
    var translatedWord: String
    var masteryLevel: MasteryLevel
    var wordBlockIndex: Int
    var dateAdded: Date

    init(
        nativeWord: String,
        translatedWord: String = "",
        masteryLevel: MasteryLevel = .unlearned,
        wordBlockIndex: Int = 0,
        dateAdded: Date = .now
    ) {
        self.nativeWord = nativeWord
        self.translatedWord = translatedWord
        self.masteryLevel = masteryLevel
        self.wordBlockIndex = wordBlockIndex
        self.dateAdded = dateAdded
    }
}
