import SwiftUI
import SwiftData

/// Achievements dashboard — shows streak stats and badge collection.
struct AchievementsView: View {
    @Query private var trackers: [StreakTracker]

    private var tracker: StreakTracker {
        if let existing = trackers.first {
            return existing
        }
        // Should never happen if ContentView seeds it.
        return StreakTracker()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Streak Stats
                streakSection

                // MARK: - Achievements Grid
                achievementsSection
            }
            .padding()
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Streak Section

    private var streakSection: some View {
        VStack(spacing: 16) {
            // Flame icon + current streak
            HStack(spacing: 12) {
                Image(systemName: tracker.currentStreak > 0 ? "flame.fill" : "flame")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        tracker.currentStreak > 0
                            ? LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom)
                            : LinearGradient(colors: [.gray.opacity(0.3), .gray.opacity(0.2)], startPoint: .top, endPoint: .bottom)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(tracker.currentStreak)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.primary)

                    Text("day streak")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    statRow(icon: "trophy.fill", label: "Best", value: "\(tracker.longestStreak) days")
                    statRow(icon: "calendar", label: "Total", value: "\(tracker.totalDaysPracticed) days")
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.appSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [.orange.opacity(0.3), .red.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: tracker.currentStreak > 0 ? .orange.opacity(0.1) : .clear, radius: 10, x: 0, y: 4)
            )

            // Quick stats row
            HStack(spacing: 12) {
                quickStat(icon: "book.fill", value: "\(tracker.totalWordsReviewed)", label: "Words")
                quickStat(icon: "gamecontroller.fill", value: "\(tracker.totalGamesPlayed)", label: "Games")
                quickStat(icon: "headphones", value: "\(tracker.totalAudioSessions)", label: "Audio")
            }
        }
    }

    private func statRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.primary)
        }
    }

    private func quickStat(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.appSurface)
        )
    }

    // MARK: - Achievements Section

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Badges")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(tracker.achievements) { achievement in
                    achievementBadge(achievement)
                }
            }
        }
    }

    private func achievementBadge(_ achievement: Achievement) -> some View {
        let color = Color(hex: achievement.colorHex)

        return VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        achievement.isUnlocked
                            ? LinearGradient(colors: [color.opacity(0.2), color.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 56, height: 56)

                Image(systemName: achievement.isUnlocked ? achievement.icon : "lock.fill")
                    .font(.system(size: 22))
                    .foregroundColor(achievement.isUnlocked ? color : .gray.opacity(0.4))
            }

            Text(achievement.title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.appSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            achievement.isUnlocked ? color.opacity(0.2) : Color.gray.opacity(0.1),
                            lineWidth: 1
                        )
                )
        )
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
}

#Preview {
    NavigationStack {
        AchievementsView()
    }
    .modelContainer(for: StreakTracker.self)
}
