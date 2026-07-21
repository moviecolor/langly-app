import SwiftUI
import SwiftData

/// Vocabulary module — 3 buttons: Add Word Block, Word Match Madness, Audio Mode.
struct VocabularyView: View {
    @EnvironmentObject var iapManager: IAPManager
    @Environment(\.modelContext) private var modelContext
    @Query private var wordBlocks: [WordBlock]
    @Query private var vocabularyWords: [VocabularyWord]

    @State private var selectedMode: VocabularyMode?
    @State private var showWordInput = false
    @State private var showNewBlockAlert = false
    @State private var newBlockName: String = ""
    @State private var mixAllBlocks: Bool = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // Block summary.
                    blockSummary

                    // Word Match Madness button.
                    if vocabularyWords.count >= 2 {
                        FeatureCardButton(
                            icon: "gamecontroller.fill",
                            iconGradientColors: [Color(hex: 0xFF6B35), Color(hex: 0xFF8F5E)],
                            title: "Word Match Madness",
                            subtitle: "Match English and Portuguese pairs before time runs out",
                            accentColors: [Color(hex: 0xFF6B35).opacity(0.4), Color(hex: 0x00D4AA).opacity(0.3)],
                            action: { selectedMode = .matchMadness }
                        )
                    }

                    // Mix All Blocks button.
                    if wordBlocks.count > 1 {
                        FeatureCardButton(
                            icon: "shuffle",
                            iconGradientColors: [Color(hex: 0x9B59B6), Color(hex: 0x8E44AD)],
                            title: "Mix All Blocks",
                            subtitle: "Combine words from all blocks into one game",
                            accentColors: [Color(hex: 0x9B59B6).opacity(0.4), Color(hex: 0x00D4AA).opacity(0.3)],
                            accessory: .toggle(isOn: mixAllBlocks, activeColor: Color(hex: 0x9B59B6)),
                            action: {
                                mixAllBlocks.toggle()
                                if mixAllBlocks { selectedMode = .matchMadness }
                            }
                        )
                    }

                    // Audio Mode button.
                    if !wordBlocks.isEmpty {
                        FeatureCardButton(
                            icon: "speaker.wave.3.fill",
                            iconGradientColors: [Color(hex: 0x3498DB), Color(hex: 0x2980B9)],
                            title: "Audio Mode",
                            subtitle: "Listen on repeat, memorize, and speak out loud. Set repeats and gap in settings.",
                            accentColors: [Color(hex: 0x3498DB).opacity(0.4), Color(hex: 0x00D4AA).opacity(0.3)],
                            action: { selectedMode = .audioMode }
                        )
                    }

                    // Add Word Block button.
                    addBlockButton

                    // Block cards.
                    if wordBlocks.isEmpty {
                        emptyState
                    } else {
                        ForEach(wordBlocks) { block in
                            blockCard(block)
                        }

                        // Ghost block suggestion.
                        ghostBlockCard
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Vocabulary")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showWordInput = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(hex: 0x00D4AA))
                }
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationDestination(item: $selectedMode) { mode in
            switch mode {
            case .matchMadness:
                MatchMadnessGameView(mixAllBlocks: mixAllBlocks)
            case .audioMode:
                AudioModeView()
            case .wordBank:
                EmptyView()
            }
        }
        .sheet(isPresented: $showWordInput) {
            WordInputView()
        }
        .alert("New Word Block", isPresented: $showNewBlockAlert) {
            TextField("Block name", text: $newBlockName)
                .textInputAutocapitalization(.words)
            Button("Cancel", role: .cancel) { newBlockName = "" }
            Button("Create") {
                guard !newBlockName.isEmpty, wordBlocks.count < 10 else { return }
                let block = WordBlock(blockName: newBlockName, vocabularyWords: [], isActive: true)
                modelContext.insert(block)
                try? modelContext.save()
                newBlockName = ""
            }
        } message: {
            Text("Enter a name for the new word block (max 10 blocks).")
        }
    }

    // MARK: - Add Block Button

    private var addBlockButton: some View {
        Button {
            showNewBlockAlert = true
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: 0x00D4AA).opacity(0.15))
                        .frame(width: 40, height: 40)

                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex: 0x00D4AA))
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text("Add Word Block")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.primary)

                    Text("Create a new block to organize your vocabulary")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "plus.circle")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: 0x00D4AA))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.appSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(hex: 0x00D4AA).opacity(0.3), lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Block Summary

    private var blockSummary: some View {
        HStack(spacing: 12) {
            summaryCard(icon: "square.stack.3d.down.right.fill", label: "Blocks", value: "\(wordBlocks.count)/10")
            summaryCard(icon: "character.book.closed.fill", label: "Words", value: "\(vocabularyWords.count)")
            summaryCard(icon: "checkmark.circle.fill", label: "Mastered", value: "\(vocabularyWords.filter { $0.masteryLevel == .mastered }.count)")
        }
    }

    private func summaryCard(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Color(hex: 0x00D4AA))
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color(hex: 0xFF6B35))
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.appSurface))
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "book")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.5))
            Text("No word blocks yet")
                .font(.system(size: 16, weight: .bold))
            Text("Tap \"Add Word Block\" to create your first block,\nthen add words to start learning.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }

    // MARK: - Block Card

    private func blockCard(_ block: WordBlock) -> some View {
        let activeWords = block.vocabularyWords.count
        let maxWords = 15
        let progress = Double(activeWords) / Double(maxWords)

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: block.isActive ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(block.isActive ? Color(hex: 0x00D4AA) : .secondary)
                        .font(.system(size: 14))
                    Text(block.blockName)
                        .font(.system(size: 15, weight: .semibold))
                }

                Spacer()

                Text("\(activeWords)/\(maxWords) words")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            // Progress bar.
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: 0x00D4AA))
                        .frame(width: geo.size.width * progress, height: 6)
                }
            }
            .frame(height: 6)

            // English words list — compact tag layout.
            if !block.vocabularyWords.isEmpty {
                let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 3)
                LazyVGrid(columns: columns, spacing: 6) {
                    ForEach(block.vocabularyWords) { word in
                        Text(word.nativeWord)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: 0x00D4AA).opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(hex: 0x00D4AA).opacity(0.2), lineWidth: 0.5)
                            )
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.appSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(hex: 0x00D4AA).opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - Ghost Block Card

    /// Empty block card suggesting the user add new words.
    private var ghostBlockCard: some View {
        Button {
            showNewBlockAlert = true
        } label: {
            VStack(alignment: .center, spacing: 8) {
                Image(systemName: "plus.circle.dashed")
                    .font(.system(size: 28))
                    .foregroundStyle(Color(hex: 0x00D4AA).opacity(0.5))

                Text("Add a New Block")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)

                Text("Create another block to organize\nyour growing vocabulary")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(hex: 0x00D4AA).opacity(0.25), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.appSurface.opacity(0.5))
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Vocabulary Mode

enum VocabularyMode: String, Identifiable {
    case wordBank = "Word Bank"
    case matchMadness = "Match Madness"
    case audioMode = "Audio Mode"

    var id: String { rawValue }
}
