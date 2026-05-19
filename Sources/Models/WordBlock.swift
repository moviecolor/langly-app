import Foundation
import SwiftData

/// A named block of vocabulary words (up to 15 words per block, up to 10 blocks).
@Model
final class WordBlock {
    var id: UUID
    var blockName: String
    @Relationship(deleteRule: .cascade)
    var vocabularyWords: [VocabularyWord]
    var isActive: Bool

    init(
        id: UUID = UUID(),
        blockName: String,
        vocabularyWords: [VocabularyWord] = [],
        isActive: Bool = true
    ) {
        self.id = id
        self.blockName = blockName
        self.vocabularyWords = vocabularyWords
        self.isActive = isActive
    }
}
