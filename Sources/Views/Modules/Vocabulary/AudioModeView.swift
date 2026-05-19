import SwiftUI
import SwiftData

/// Audio Mode view — continuous word playback with TTS.
/// User selects word blocks, sets repetitions and gap, then plays.
struct AudioModeView: View {
    @StateObject private var viewModel = AudioModeViewModel()
    @Environment(\.modelContext) private var modelContext
    @Query private var wordBlocks: [WordBlock]

    init() {}

    var body: some View {
        ZStack {
            // Background gradient.
            LinearGradient(
                colors: [
                    Color.appBackground,
                    Color.appBackground.opacity(0.9),
                    Color(hex: 0x00D4AA).opacity(0.1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Current word display.
                    currentWordDisplay

                    // Progress indicator.
                    progressIndicator

                    Divider()
                        .background(Color(hex: 0x00D4AA).opacity(0.3))

                    // Playback controls.
                    playbackControls

                    Divider()
                        .background(Color(hex: 0x00D4AA).opacity(0.3))

                    // Settings: repetitions and gap.
                    settingsSection

                    Divider()
                        .background(Color(hex: 0x00D4AA).opacity(0.3))

                    // Word block selection.
                    blockSelectionSection
                }
                .padding()
            }
        }
        .navigationTitle("Audio Mode")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadBlocks(wordBlocks)
        }
    }

    // MARK: - Current Word Display

    private var currentWordDisplay: some View {
        VStack(spacing: 12) {
            if let word = viewModel.currentWord {
                Text(word.nativeWord)
                    .font(.title2.bold())
                    .foregroundStyle(Color(hex: 0x00D4AA))

                Text(word.translatedWord)
                    .font(.title)
                    .foregroundStyle(Color(hex: 0xFF6B35))

                if !viewModel.currentUtteranceType.isEmpty {
                    Text(viewModel.currentUtteranceType.capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.appSurface.opacity(0.8))
                        )
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "waveform")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.5))

                    Text("Select blocks and press Play")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appSurface.opacity(0.6))
        )
    }

    // MARK: - Progress Indicator

    private var progressIndicator: some View {
        HStack(spacing: 12) {
            Text("\(viewModel.progressIndex)/\(viewModel.totalWordsInQueue)")
                .font(.caption.monospacedDigit())
                .foregroundColor(.secondary)

            ProgressView(value: viewModel.totalWordsInQueue > 0 ? Double(viewModel.progressIndex) : 0, total: Double(viewModel.totalWordsInQueue))
                .tint(Color(hex: 0x00D4AA))
        }
    }

    // MARK: - Playback Controls

    private var playbackControls: some View {
        HStack(spacing: 16) {
            switch viewModel.playbackState {
            case .stopped:
                Button {
                    viewModel.startPlayback()
                } label: {
                    Label("Play", systemImage: "play.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(hex: 0x00D4AA))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .disabled(viewModel.selectedBlockIDs.isEmpty)

            case .playing:
                Button {
                    viewModel.pausePlayback()
                } label: {
                    Label("Pause", systemImage: "pause.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(hex: 0xFF6B35))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                Button {
                    viewModel.stopPlayback()
                } label: {
                    Label("Stop", systemImage: "stop.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.red.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

            case .paused:
                Button {
                    viewModel.resumePlayback()
                } label: {
                    Label("Resume", systemImage: "play.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(hex: 0x00D4AA))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                Button {
                    viewModel.stopPlayback()
                } label: {
                    Label("Stop", systemImage: "stop.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.red.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        VStack(spacing: 20) {
            // Repetitions slider.
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Repetitions")
                        .font(.subheadline.bold())
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("\(viewModel.repetitions)x")
                        .font(.subheadline.monospacedDigit().bold())
                        .foregroundStyle(Color(hex: 0xFF6B35))
                }

                Slider(
                    value: Binding(
                        get: { Double(viewModel.repetitions) },
                        set: { viewModel.repetitions = max(1, min(9, Int($0))) }
                    ),
                    in: 1...9,
                    step: 1
                )
                .tint(Color(hex: 0xFF6B35))
            }

            // Gap slider.
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Gap Between Words")
                        .font(.subheadline.bold())
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(String(format: "%.1fs", viewModel.gapSeconds))
                        .font(.subheadline.monospacedDigit().bold())
                        .foregroundStyle(Color(hex: 0x00D4AA))
                }

                Slider(
                    value: $viewModel.gapSeconds,
                    in: 0.5...3.0,
                    step: 0.25
                )
                .tint(Color(hex: 0x00D4AA))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.appSurface.opacity(0.6))
        )
    }

    // MARK: - Block Selection Section

    private var blockSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Word Blocks")
                    .font(.headline)
                    .foregroundStyle(Color(hex: 0x00D4AA))

                Spacer()

                HStack(spacing: 8) {
                    Button("Select All") {
                        viewModel.selectAllActiveBlocks()
                    }
                    .font(.caption)
                    .foregroundColor(Color(hex: 0x00D4AA))

                    Button("Clear") {
                        viewModel.clearSelection()
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }

            if wordBlocks.isEmpty {
                Text("No word blocks yet. Add words in the Word Bank.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 20)
            } else {
                ForEach(wordBlocks) { block in
                    blockRow(block)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.appSurface.opacity(0.6))
        )
    }

    /// Individual block selection row.
    private func blockRow(_ block: WordBlock) -> some View {
        let isSelected = viewModel.selectedBlockIDs.contains(block.id)
        let wordCount = block.vocabularyWords.count

        return Button {
            viewModel.toggleBlockSelection(block.id)
        } label: {
            HStack {
                // Checkbox.
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.title2)
                    .foregroundStyle(isSelected ? Color(hex: 0x00D4AA) : .secondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(block.blockName)
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)

                    Text("\(wordCount) word\(wordCount == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if !block.isActive {
                    Text("Inactive")
                        .font(.caption)
                        .foregroundColor(.red.opacity(0.7))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color.red.opacity(0.15))
                        )
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AudioModeView()
            .modelContainer(for: [WordBlock.self, VocabularyWord.self], inMemory: true)
    }
}
