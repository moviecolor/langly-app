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

                    // MARK: - Session Heatmap
                    heatmapSection(stats)

                    // MARK: - Word Difficulty
                    difficultySection(stats)

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

    // MARK: - Heatmap Section

    private func heatmapSection(_ stats: LocalAnalytics) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("When You Practice")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)

                Spacer()

                if stats.peakHour != nil {
                    Text("Peak: \(stats.formattedPeakHour)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: 0x00D4AA))
                }
            }

            // 24-hour heatmap grid.
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 12), spacing: 2) {
                ForEach(0..<24, id: \.self) { hour in
                    let count = hour < stats.hourlyUsage.count ? stats.hourlyUsage[hour] : 0
                    let maxCount = stats.hourlyUsage.max() ?? 1
                    let intensity = maxCount > 0 ? Double(count) / Double(maxCount) : 0

                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(hex: 0x00D4AA).opacity(intensity > 0 ? max(0.2, intensity) : 0.05))
                        .frame(height: 20)
                        .overlay(
                            Text("\(hour)")
                                .font(.system(size: 7))
                                .foregroundColor(.secondary.opacity(0.6))
                        )
                }
            }

            Text("Each cell = 1 hour of the day. Darker = more practice.")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.7))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.appSurface)
        )
    }

    // MARK: - Difficulty Section

    private func difficultySection(_ stats: LocalAnalytics) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tricky Words")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)

            let difficult = stats.difficultWords(limit: 5)

            if difficult.isEmpty {
                Text("No errors tracked yet. Play some games to see which words trip you up!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 8) {
                    ForEach(difficult, id: \.word) { item in
                        HStack {
                            Text(item.word)
                                .font(.subheadline.bold())
                                .foregroundColor(.primary)

                            Spacer()

                            HStack(spacing: 4) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.red.opacity(0.7))
                                Text("\(item.errors) errors")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)

                        if item.word != difficult.last?.word {
                            Divider()
                                .background(Color.gray.opacity(0.2))
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.appSurface)
        )
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
