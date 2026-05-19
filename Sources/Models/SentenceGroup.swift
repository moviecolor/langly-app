import Foundation
import SwiftData

/// A named group of sentences (e.g. "Greetings", "At the Restaurant").
@Model
final class SentenceGroup {
    var groupName: String
    @Relationship(deleteRule: .cascade)
    var sentences: [Sentence]
    var isActive: Bool

    init(
        groupName: String,
        sentences: [Sentence] = [],
        isActive: Bool = true
    ) {
        self.groupName = groupName
        self.sentences = sentences
        self.isActive = isActive
    }
}
