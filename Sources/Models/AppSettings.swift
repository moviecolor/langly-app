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
    var hasCompletedOnboarding: Bool
    /// First-launch timestamp. Drives the 7-day full-access trial:
    /// after 7 days, non-subscribers shrink to 3 word blocks.
    var installDate: Date?

    init(
        homeLanguage: String = "English",
        targetLanguage: String = "Portuguese",
        selectedVoice: String = "",
        playbackGap: Double = 1.75,
        loopEnabled: Bool = true,
        totalWordsLearned: Int = 0,
        hasCompletedOnboarding: Bool = false,
        installDate: Date? = nil
    ) {
        self.homeLanguage = homeLanguage
        self.targetLanguage = targetLanguage
        self.selectedVoice = selectedVoice
        self.playbackGap = playbackGap
        self.loopEnabled = loopEnabled
        self.totalWordsLearned = totalWordsLearned
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.installDate = installDate
    }
}
