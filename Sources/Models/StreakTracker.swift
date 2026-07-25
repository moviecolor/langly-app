import Foundation
import SwiftData

/// Tracks daily learning streak and achievement badges.
@Model
final class StreakTracker {
    var currentStreak: Int
    var longestStreak: Int
    var lastPracticeDate: Date?
    var totalDaysPracticed: Int
    var totalWordsReviewed: Int
    var totalGamesPlayed: Int
    var totalAudioSessions: Int
    var dateCreated: Date

    init(
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastPracticeDate: Date? = nil,
        totalDaysPracticed: Int = 0,
        totalWordsReviewed: Int = 0,
        totalGamesPlayed: Int = 0,
        totalAudioSessions: Int = 0,
        dateCreated: Date = .now
    ) {
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastPracticeDate = lastPracticeDate
        self.totalDaysPracticed = totalDaysPracticed
        self.totalWordsReviewed = totalWordsReviewed
        self.totalGamesPlayed = totalGamesPlayed
        self.totalAudioSessions = totalAudioSessions
        self.dateCreated = dateCreated
    }

    /// Call this whenever the user practices. Updates streak logic.
    func recordPractice() {
        let today = Calendar.current.startOfDay(for: .now)

        if let lastDate = lastPracticeDate {
            let lastDay = Calendar.current.startOfDay(for: lastDate)
            let daysBetween = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0

            if daysBetween == 0 {
                // Already practiced today — just increment counters.
            } else if daysBetween == 1 {
                // Consecutive day — extend streak.
                currentStreak += 1
                totalDaysPracticed += 1
            } else {
                // Streak broken — restart.
                currentStreak = 1
                totalDaysPracticed += 1
            }
        } else {
            // First ever practice.
            currentStreak = 1
            totalDaysPracticed = 1
        }

        lastPracticeDate = .now
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
    }

    /// All achievements derived from tracker data.
    var achievements: [Achievement] {
        [
            Achievement(
                id: "first_word",
                title: "First Word",
                description: "Reviewed your first word",
                icon: "star.fill",
                colorHex: 0xFFD700,
                isUnlocked: totalWordsReviewed >= 1
            ),
            Achievement(
                id: "ten_words",
                title: "Word Explorer",
                description: "Reviewed 10 words",
                icon: "book.fill",
                colorHex: 0xFF6B35,
                isUnlocked: totalWordsReviewed >= 10
            ),
            Achievement(
                id: "fifty_words",
                title: "Vocabulary Builder",
                description: "Reviewed 50 words",
                icon: "books.vertical.fill",
                colorHex: 0x00D4AA,
                isUnlocked: totalWordsReviewed >= 50
            ),
            Achievement(
                id: "hundred_words",
                title: "Word Master",
                description: "Reviewed 100 words",
                icon: "crown.fill",
                colorHex: 0xB57EDC,
                isUnlocked: totalWordsReviewed >= 100
            ),
            Achievement(
                id: "streak_3",
                title: "On Fire",
                description: "3-day streak",
                icon: "flame.fill",
                colorHex: 0xFF4500,
                isUnlocked: longestStreak >= 3
            ),
            Achievement(
                id: "streak_7",
                title: "Week Warrior",
                description: "7-day streak",
                icon: "flame.circle.fill",
                colorHex: 0xFF6347,
                isUnlocked: longestStreak >= 7
            ),
            Achievement(
                id: "streak_30",
                title: "Monthly Master",
                description: "30-day streak",
                icon: "star.circle.fill",
                colorHex: 0xFFD700,
                isUnlocked: longestStreak >= 30
            ),
            Achievement(
                id: "game_5",
                title: "Game On",
                description: "Played 5 games",
                icon: "gamecontroller.fill",
                colorHex: 0x3498DB,
                isUnlocked: totalGamesPlayed >= 5
            ),
            Achievement(
                id: "game_25",
                title: "Gaming Pro",
                description: "Played 25 games",
                icon: "gamecontroller.fill",
                colorHex: 0x9B59B6,
                isUnlocked: totalGamesPlayed >= 25
            ),
            Achievement(
                id: "audio_10",
                title: "Listen Up",
                description: "10 audio sessions",
                icon: "headphones",
                colorHex: 0xE74C3C,
                isUnlocked: totalAudioSessions >= 10
            ),
        ]
    }
}

/// A single achievement badge.
struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let colorHex: UInt
    let isUnlocked: Bool
}
