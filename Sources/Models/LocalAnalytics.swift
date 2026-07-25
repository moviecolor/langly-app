import Foundation
import SwiftData

/// Local-only analytics — tracks user engagement metrics entirely on-device.
/// No data is ever transmitted off-device. Fully privacy-compliant.
@Model
final class LocalAnalytics {
    // MARK: - Session Tracking
    var totalSessionCount: Int
    var totalSessionDurationSeconds: Double
    var lastSessionDate: Date?
    var firstLaunchDate: Date

    // MARK: - Word Tracking
    var totalWordsAdded: Int
    var totalWordsReviewed: Int
    var totalWordsMastered: Int

    // MARK: - Game Tracking
    var totalGamesPlayed: Int
    var totalGameMatches: Int
    var bestGameScore: Int

    // MARK: - Audio Tracking
    var totalAudioSessions: Int
    var totalAudioDurationSeconds: Double

    // MARK: - Streak
    var currentStreak: Int
    var longestStreak: Int

    // MARK: - Feature Usage
    var vocabularyViewOpens: Int
    var matchMadnessOpens: Int
    var audioModeOpens: Int
    var settingsOpens: Int

    init() {
        self.totalSessionCount = 0
        self.totalSessionDurationSeconds = 0
        self.lastSessionDate = nil
        self.firstLaunchDate = .now
        self.totalWordsAdded = 0
        self.totalWordsReviewed = 0
        self.totalWordsMastered = 0
        self.totalGamesPlayed = 0
        self.totalGameMatches = 0
        self.bestGameScore = 0
        self.totalAudioSessions = 0
        self.totalAudioDurationSeconds = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.vocabularyViewOpens = 0
        self.matchMadnessOpens = 0
        self.audioModeOpens = 0
        self.settingsOpens = 0
    }

    // MARK: - Tracking Methods

    /// Record a word being added.
    func trackWordAdded() {
        totalWordsAdded += 1
    }

    /// Record words being reviewed (e.g., in a game).
    func trackWordsReviewed(count: Int) {
        totalWordsReviewed += count
    }

    /// Record a word reaching mastered status.
    func trackWordMastered() {
        totalWordsMastered += 1
    }

    /// Record a game completion.
    func trackGameCompleted(matches: Int, score: Int) {
        totalGamesPlayed += 1
        totalGameMatches += matches
        if score > bestGameScore {
            bestGameScore = score
        }
    }

    /// Record an audio session (when user stops playback).
    func trackAudioSession(durationSeconds: Double = 0) {
        totalAudioSessions += 1
        totalAudioDurationSeconds += durationSeconds
    }

    /// Record a feature screen open.
    func trackFeatureOpen(_ feature: AnalyticsFeature) {
        switch feature {
        case .vocabulary: vocabularyViewOpens += 1
        case .matchMadness: matchMadnessOpens += 1
        case .audioMode: audioModeOpens += 1
        case .settings: settingsOpens += 1
        }
    }

    /// Record a session and update streak.
    func recordSession(durationSeconds: Double = 0) {
        totalSessionCount += 1
        totalSessionDurationSeconds += durationSeconds
        lastSessionDate = .now
    }

    // MARK: - Computed Stats

    /// Average words per game session.
    var averageWordsPerGame: Int {
        guard totalGamesPlayed > 0 else { return 0 }
        return totalGameMatches / totalGamesPlayed
    }

    /// Average session duration in minutes.
    var averageSessionMinutes: Double {
        guard totalSessionCount > 0 else { return 0 }
        return (totalSessionDurationSeconds / Double(totalSessionCount)) / 60.0
    }

    /// Total practice time formatted.
    var formattedTotalTime: String {
        let hours = Int(totalSessionDurationSeconds) / 3600
        let minutes = (Int(totalSessionDurationSeconds) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    /// Days since first launch.
    var daysSinceLaunch: Int {
        Calendar.current.dateComponents([.day], from: firstLaunchDate, to: .now).day ?? 0
    }
}

/// Features that can be tracked.
enum AnalyticsFeature: String, CaseIterable {
    case vocabulary = "Vocabulary"
    case matchMadness = "Match Madness"
    case audioMode = "Audio Mode"
    case settings = "Settings"
}
