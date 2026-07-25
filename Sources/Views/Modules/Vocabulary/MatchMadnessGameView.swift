import SwiftUI
import SwiftData

/// Match Madness game view — dual-column word matching game.
/// Players match English words with their Portuguese translations within 1:45.
struct MatchMadnessGameView: View {
    @StateObject private var viewModel = MatchMadnessViewModel()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var wordBlocks: [WordBlock]
    @Query private var trackers: [StreakTracker]
    @Query private var analytics: [LocalAnalytics]
    let mixAllBlocks: Bool

    init(mixAllBlocks: Bool = false) {
        self.mixAllBlocks = mixAllBlocks
    }

    /// Whether the game complete overlay is showing.
    @State private var showCompleteOverlay: Bool = false

    var body: some View {
        ZStack {
            // Background gradient.
            LinearGradient(
                colors: [
                    Color.appBackground,
                    Color.appBackground.opacity(0.9),
                    Color(hex: 0xFF6B35).opacity(0.1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header: Timer, Score, Controls.
                gameHeader

                Divider()
                    .background(Color(hex: 0x00D4AA).opacity(0.3))
                    .padding(.vertical, 8)

                // Game board: two columns of word buttons.
                gameBoard

                Spacer()

                // Bottom controls: Jumble toggle + Start/Stop/Restart.
                bottomControls
            }
            .padding()
        }
        .navigationTitle("Match Madness")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if mixAllBlocks {
                viewModel.loadAllBlocks(from: wordBlocks)
            } else {
                viewModel.loadWords(from: wordBlocks)
            }
            viewModel.startGame()
        }
        .onChange(of: viewModel.gameState) { _, newState in
            if newState == .complete {
                showCompleteOverlay = true
                HapticPattern.notification.trigger()
                // Track streak progress.
                if let tracker = trackers.first {
                    tracker.totalGamesPlayed += 1
                    tracker.totalWordsReviewed += viewModel.totalMatches
                    tracker.recordPractice()
                    try? modelContext.save()
                }
                // Track analytics.
                if let stats = analytics.first {
                    stats.trackGameCompleted(matches: viewModel.totalMatches, score: viewModel.score)
                    stats.trackWordsReviewed(count: viewModel.totalMatches)
                    try? modelContext.save()
                }
            }
        }
        .onChange(of: viewModel.lastMatchCorrect) { _, correct in
            if let correct = correct {
                if correct {
                    HapticPattern.success.trigger()
                } else {
                    HapticPattern.error.trigger()
                    // Track word error for analytics.
                    if let word = viewModel.lastWrongWord, let stats = analytics.first {
                        stats.trackWordError(word: word)
                        try? modelContext.save()
                    }
                }
            }
        }
        .overlay {
            if showCompleteOverlay {
                gameCompleteOverlay
            }
        }
    }

    // MARK: - Header

    private var gameHeader: some View {
        HStack {
            // Timer.
            VStack(alignment: .leading, spacing: 2) {
                Text("Time")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(formatTime(viewModel.timeRemaining))
                    .font(.title2.monospacedDigit().bold())
                    .foregroundStyle(
                        viewModel.timeRemaining <= 15
                            ? Color(hex: 0xFF6B35)
                            : Color(hex: 0x00D4AA)
                    )
            }

            Spacer()

            // Score.
            VStack(alignment: .trailing, spacing: 2) {
                Text("Score")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(viewModel.score)")
                    .font(.title2.monospacedDigit().bold())
                    .foregroundStyle(Color(hex: 0xFF6B35))
            }
        }
    }

    // MARK: - Game Board

    private var gameBoard: some View {
        HStack(spacing: 20) {
            // Left column.
            VStack(spacing: 10) {
                Text("Column A")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)

                ForEach(viewModel.leftColumn) { word in
                    wordButton(word, column: .left)
                }
            }

            // Right column.
            VStack(spacing: 10) {
                Text("Column B")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)

                ForEach(viewModel.rightColumn) { word in
                    wordButton(word, column: .right)
                }
            }
        }
    }

    /// Individual word button with selection/match/wrong states.
    @ViewBuilder
    private func wordButton(_ word: MatchWord, column: ColumnSide) -> some View {
        let isSelected = (column == .left && viewModel.selectedLeft?.id == word.id)
            || (column == .right && viewModel.selectedRight?.id == word.id)

        Button {
            if column == .left {
                viewModel.selectLeftWord(word)
            } else {
                viewModel.selectRightWord(word)
            }
        } label: {
            Text(column == .left ? word.nativeWord : word.translatedWord)
                .font(.callout)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .foregroundColor(isSelected ? .white : .black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            isSelected
                                ? Color(hex: 0xFF6B35)
                                : Color.appSurface.opacity(0.8)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    isSelected
                                        ? Color(hex: 0xFF6B35).opacity(0.8)
                                        : Color(hex: 0x00D4AA).opacity(0.3),
                                    lineWidth: 1.5
                                )
                        )
                )
        }
        .disabled(viewModel.gameState != .playing)
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        VStack(spacing: 16) {
            // Block toggles section — shows all blocks with ON/OFF switches.
            if wordBlocks.count > 1 {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Word Blocks")
                        .font(.subheadline.bold())
                        .foregroundColor(.secondary)

                    ForEach(wordBlocks.filter { $0.isActive }) { block in
                        HStack {
                            Image(systemName: viewModel.activeBlockNames.contains(block.blockName)
                                  ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(viewModel.activeBlockNames.contains(block.blockName)
                                                 ? Color(hex: 0x00D4AA) : .secondary)

                            Text(block.blockName)
                                .font(.subheadline)

                            Spacer()

                            Text("\(block.vocabularyWords.count) words")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.toggleBlock(block.blockName, blocks: wordBlocks)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }

            // Jumble toggle.
            HStack {
                Text("Jumble Columns")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                Toggle("", isOn: Binding(
                    get: { viewModel.isJumbleEnabled },
                    set: { _ in viewModel.toggleJumble() }
                ))
                .labelsHidden()
                .tint(Color(hex: 0xFF6B35))
            }
            .padding(.horizontal, 4)

            // Game control buttons.
            HStack(spacing: 16) {
                switch viewModel.gameState {
                case .idle:
                    gameActionButton(label: "Back", icon: "chevron.left",
                                     background: Color(hex: 0x00D4AA)) {
                        dismiss()
                    }

                case .playing:
                    gameActionButton(label: "Pause", icon: "pause.fill",
                                     background: Color(hex: 0xFF6B35)) {
                        viewModel.pauseGame()
                    }
                    gameActionButton(label: "Stop", icon: "stop.fill",
                                     background: Color.red.opacity(0.8)) {
                        viewModel.stopGame()
                    }

                case .paused:
                    gameActionButton(label: "Resume", icon: "play.fill",
                                     background: Color(hex: 0x00D4AA)) {
                        viewModel.resumeGame()
                    }
                    gameActionButton(label: "Stop", icon: "stop.fill",
                                     background: Color.red.opacity(0.8)) {
                        viewModel.stopGame()
                    }

                case .complete:
                    EmptyView()
                }
            }
        }
    }

    // MARK: - Game Complete Overlay

    private var gameCompleteOverlay: some View {
        ZStack {
            Color.appBackground.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: 0xFF6B35), Color(hex: 0x00D4AA)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("Game Over!")
                    .font(.title.bold())
                    .foregroundStyle(Color(hex: 0x00D4AA))

                VStack(spacing: 8) {
                    statRow(label: "Matches", value: "\(viewModel.totalMatches)")
                    statRow(label: "Wrong Attempts", value: "\(viewModel.wrongAttempts)")
                    statRow(label: "Final Score", value: "\(viewModel.score)")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.appSurface.opacity(0.9))
                )

                HStack(spacing: 16) {
                    Button {
                        viewModel.resetToIdle()
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120)
                            .padding(.vertical, 12)
                            .background(Color(hex: 0x00D4AA))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)

                    Button {
                        showCompleteOverlay = false
                        viewModel.restartGame()
                    } label: {
                        Text("Play Again")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120)
                            .padding(.vertical, 12)
                            .background(Color(hex: 0xFF6B35))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.appBackground)
                    .shadow(color: Color(hex: 0xFF6B35).opacity(0.3), radius: 20)
            )
            .padding(.horizontal, 32)
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: showCompleteOverlay)
    }

    // MARK: - Helpers

    /// Shared game action button to eliminate duplicated button code.
    private func gameActionButton(label: String, icon: String, background: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(label, systemImage: icon)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(background)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    /// Formats seconds into MM:SS.
    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }

    /// A single stat row for the game complete overlay.
    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.bold())
                .foregroundStyle(Color(hex: 0x00D4AA))
        }
    }
}

// MARK: - Supporting Types

/// Which column a word button belongs to.
private enum ColumnSide {
    case left
    case right
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MatchMadnessGameView()
            .modelContainer(for: [WordBlock.self, VocabularyWord.self], inMemory: true)
    }
}
