import SwiftUI
import SwiftData

/// Stats dashboard — displays local analytics. All data stays on-device.
struct StatsView: View {
    @Query private var analytics: [LocalAnalytics]
    @Query private var trackers: [StreakTracker]
    @Query private var words: [VocabularyWord]

    private var stats: LocalAnalytics? { analytics.first }
    private var tracker: StreakTracker? { trackers.first }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let stats = stats {
                    // MARK: - Overview Cards
                    overviewSection(stats)

                    // MARK: - Learning Stats
                    learningSection(stats)

                    // MARK: - Engagement Stats
                    engagementSection(stats)

                    // MARK: - Privacy Notice
                    privacyNotice
                } else {
                    Text("No data yet")
                        .foregroundColor(.secondary)
                        .padding(.top, 60)
                }
            }
            .padding()
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Your Stats")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Overview Section

    private func overviewSection(_ stats: LocalAnalytics) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                statCard(
                    icon: "calendar",
                    value: "\(stats.daysSinceLaunch)",
                    label: "Days",
                    color: 0x3498DB
                )
                statCard(
                    icon: "book.fill",
                    value: "\(stats.totalWordsAdded)",
                    label: "Words",
                    color: 0xFF6B35
                )
                statCard(
                    icon: "gamecontroller.fill",
                    value: "\(stats.totalGamesPlayed)",
                    label: "Games",
                    color: 0x9B59B6
                )
            }

            HStack(spacing: 12) {
                statCard(
                    icon: "headphones",
                    value: "\(stats.totalAudioSessions)",
                    label: "Audio",
                    color: 0x00D4AA
                )
                statCard(
                    icon: "flame.fill",
                    value: "\(tracker?.currentStreak ?? 0)",
                    label: "Streak",
                    color: 0xFF4500
                )
                statCard(
                    icon: "checkmark.circle.fill",
                    value: "\(stats.totalWordsMastered)",
                    label: "Mastered",
                    color: 0x00D4AA
                )
            }
        }
    }

    private func statCard(icon: String, value: String, label: String, color: UInt) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: color))

            Text(value)
                .font(.system(size: 22, weight: .bold))
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
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: color).opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - Learning Section

    private func learningSection(_ stats: LocalAnalytics) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Learning")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)

            VStack(spacing: 10) {
                statRow(label: "Words Added", value: "\(stats.totalWordsAdded)")
                statRow(label: "Words Reviewed", value: "\(stats.totalWordsReviewed)")
                statRow(label: "Words Mastered", value: "\(stats.totalWordsMastered)")
                statRow(label: "Mastery Rate", value: "\(masteryRate(stats))%")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.appSurface)
            )
        }
    }

    // MARK: - Engagement Section

    private func engagementSection(_ stats: LocalAnalytics) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Engagement")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)

            VStack(spacing: 10) {
                statRow(label: "Total Sessions", value: "\(stats.totalSessionCount)")
                statRow(label: "Total Time", value: stats.formattedTotalTime)
                statRow(label: "Games Played", value: "\(stats.totalGamesPlayed)")
                statRow(label: "Best Game Score", value: "\(stats.bestGameScore)")
                statRow(label: "Audio Sessions", value: "\(stats.totalAudioSessions)")
                statRow(label: "Longest Streak", value: "\(stats.longestStreak) days")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.appSurface)
            )
        }
    }

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
        }
    }

    private func masteryRate(_ stats: LocalAnalytics) -> Int {
        guard stats.totalWordsAdded > 0 else { return 0 }
        return Int((Double(stats.totalWordsMastered) / Double(stats.totalWordsAdded)) * 100)
    }

    // MARK: - Privacy Notice

    private var privacyNotice: some View {
        HStack(spacing: 10) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 16))
                .foregroundColor(Color(hex: 0x00D4AA))

            VStack(alignment: .leading, spacing: 2) {
                Text("100% Private")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                Text("All data stays on your device. Nothing is sent anywhere.")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: 0x00D4AA).opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: 0x00D4AA).opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    NavigationStack {
        StatsView()
    }
    .modelContainer(for: [LocalAnalytics.self, StreakTracker.self])
}
