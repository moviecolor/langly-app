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
    /// Creation timestamp. Free tier keeps the two oldest blocks after the
    /// 7-day trial ends; everything newer is locked behind Langly Premium.
    /// Optional so SwiftData lightweight-migrates existing installs (legacy
    /// rows read as nil and sort oldest → they stay free).
    var createdAt: Date?

    init(
        id: UUID = UUID(),
        blockName: String,
        vocabularyWords: [VocabularyWord] = [],
        isActive: Bool = true,
        createdAt: Date? = .now
    ) {
        self.id = id
        self.blockName = blockName
        self.vocabularyWords = vocabularyWords
        self.isActive = isActive
        self.createdAt = createdAt
    }
}
