import Foundation
import SwiftData

/// Represents the user's app-wide settings.
@Model
final class AppSettings {
    var homeLanguage: String
    var targetLanguage: String
    var selectedVoice: String
    var playbackGap: Double
    var loopEnabled: Bool
    var totalWordsLearned: Int

    init(
        homeLanguage: String = "English",
        targetLanguage: String = "Portuguese",
        selectedVoice: String = "",
        playbackGap: Double = 1.75,
        loopEnabled: Bool = true,
        totalWordsLearned: Int = 0
    ) {
        self.homeLanguage = homeLanguage
        self.targetLanguage = targetLanguage
        self.selectedVoice = selectedVoice
        self.playbackGap = playbackGap
        self.loopEnabled = loopEnabled
        self.totalWordsLearned = totalWordsLearned
    }
}
