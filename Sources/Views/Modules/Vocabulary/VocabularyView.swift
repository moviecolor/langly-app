import SwiftUI
import SwiftData

/// Vocabulary module main view — hub for word bank, Match Madness, and Audio Mode.
enum VocabularyMode: String, CaseIterable, Identifiable {
    case wordBank = "Word Bank"
    case matchMadness = "Match Madness"
    case audioMode = "Audio Mode"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .wordBank: return "book.fill"
        case .matchMadness: return "gamecontroller.fill"
        case .audioMode: return "speaker.wave.3.fill"
        }
    }
}

struct VocabularyView: View {
    @EnvironmentObject var iapManager: IAPManager
    @Environment(\.modelContext) private var modelContext
    @Query private var wordBlocks: [WordBlock]
    @Query private var vocabularyWords: [VocabularyWord]

    @State private var selectedMode: VocabularyMode = .wordBank
    @State private var showWordInput = false
    @State private var showNewBlockAlert = false
    @State private var newBlockName: String = ""

    // Scaled metrics for small screen support.
    @ScaledMetric(relativeTo: .body) var summaryIconSize: CGFloat = 22
    @ScaledMetric(relativeTo: .body) var summaryValueSize: CGFloat = 18
    @ScaledMetric(relativeTo: .body) var summaryLabelSize: CGFloat = 11
    @ScaledMetric(relativeTo: .body) var blockCardPadding: CGFloat = 14
    @ScaledMetric(relativeTo: .body) var blockNameSize: CGFloat = 16

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                Group {
                    switch selectedMode {
                    case .wordBank:
                        wordBankView
                    case .matchMadness:
                        MatchMadnessGameView()
                    case .audioMode:
                        AudioModeView()
                    }
                }
            }
            .navigationTitle("Vocabulary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    modePicker
                }

                if selectedMode == .wordBank {
                    ToolbarItem(placement: .navigationBarLeading) {
                        addBlockButton
                    }
                }
            }
            .toolbarBackground(Color.appBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showWordInput) {
                WordInputView()
            }
            .alert("New Word Block", isPresented: $showNewBlockAlert) {
                TextField("Block name", text: $newBlockName)
                    .textInputAutocapitalization(.words)

                Button("Cancel", role: .cancel) {
                    newBlockName = ""
                }
                Button("Create") {
                    createNewBlock()
                }
            } message: {
                Text("Enter a name for the new word block (max 10 blocks).")
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
    }

    // MARK: - Word Bank View

    private var wordBankView: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 16) {
                    // Block summary — scaled for small screens.
                    blockSummary

                    // Inline "Add Words" button — always visible when blocks exist.
                    if !wordBlocks.isEmpty {
                        addWordButtonInline
                    }

                    // Block cards.
                    if wordBlocks.isEmpty {
                        emptyState
                    } else {
                        ForEach(wordBlocks) { block in
                            blockCard(block)
                        }
                    }
                }
                .padding()
                .frame(minHeight: geo.size.height)
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
        }
    }

    // MARK: - Block Summary

    private var blockSummary: some View {
        HStack(spacing: 12) {
            summaryCard(
                icon: "square.stack.3d.down.right.fill",
                label: "Blocks",
                value: "\(wordBlocks.count)/10"
            )

            summaryCard(
                icon: "character.book.closed.fill",
                label: "Words",
                value: "\(vocabularyWords.count)"
            )

            summaryCard(
                icon: "checkmark.circle.fill",
                label: "Mastered",
                value: "\(vocabularyWords.filter { $0.masteryLevel == .mastered }.count)"
            )
        }
    }

    private func summaryCard(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: summaryIconSize))
                .foregroundStyle(Color(hex: 0x00D4AA))

            Text(value)
                .font(.system(size: summaryValueSize, weight: .bold))
                .foregroundStyle(Color(hex: 0xFF6B35))

            Text(label)
                .font(.system(size: summaryLabelSize))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.appSurface)
        )
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "book")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.5))

            Text("No word blocks yet")
                .font(.system(size: 16, weight: .bold))

            Text("Tap + to create your first block,\nthen tap \"Add Words\" to start building your vocabulary.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }

    // MARK: - Inline Add Words Button

    private var addWordButtonInline: some View {
        Button {
            showWordInput = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16))
                Text("Add Words")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color(hex: 0x00D4AA))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Block Card

    private func blockCard(_ block: WordBlock) -> some View {
        let activeWords = block.vocabularyWords.count
        let maxWords = 15
        let progress = Double(activeWords) / Double(maxWords)

        return VStack(alignment: .leading, spacing: 10) {
            // Header.
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: block.isActive ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(block.isActive ? Color(hex: 0x00D4AA) : .secondary)
                        .font(.system(size: 14))

                    Text(block.blockName)
                        .font(.system(size: blockNameSize, weight: .semibold))
                }

                Spacer()

                // Active toggle.
                Toggle("", isOn: Binding(
                    get: { block.isActive },
                    set: { block.isActive = $0 }
                ))
                .labelsHidden()
                .tint(Color(hex: 0x00D4AA))
                .toggleStyle(.switch)
                .scaleEffect(0.8)
            }

            // Progress bar.
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(activeWords)/\(maxWords) words")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                ProgressView(value: progress)
                    .tint(activeWords >= maxWords ? Color(hex: 0x00D4AA) : Color(hex: 0xFF6B35))
                    .scaleEffect(y: 0.8)
            }

            // Mastery breakdown.
            HStack(spacing: 10) {
                masteryBadge(count: block.vocabularyWords.filter { $0.masteryLevel == .mastered }.count, label: "Mastered", color: Color(hex: 0x00D4AA))
                masteryBadge(count: block.vocabularyWords.filter { $0.masteryLevel == .learning }.count, label: "Learning", color: Color(hex: 0xFF6B35))
                masteryBadge(count: block.vocabularyWords.filter { $0.masteryLevel == .unlearned }.count, label: "New", color: .secondary)
            }

            // Inline "Add Words" button on each block.
            if activeWords < maxWords {
                Button {
                    showWordInput = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 12))
                        Text("Add Word to \(block.blockName)")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(Color(hex: 0x00D4AA))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(hex: 0x00D4AA).opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }

            // Delete button.
            HStack {
                Spacer()
                Button("Delete Block", role: .destructive) {
                    deleteBlock(block)
                }
                .font(.system(size: 11))
            }
        }
        .padding(blockCardPadding)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.appSurface)
        )
    }

    private func masteryBadge(count: Int, label: String, color: Color) -> some View {
        HStack(spacing: 3) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)

            Text("\(count) \(label)")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Toolbar Items

    private var modePicker: some View {
        Menu {
            Picker("Mode", selection: $selectedMode) {
                ForEach(VocabularyMode.allCases) { mode in
                    Label(mode.rawValue, systemImage: mode.icon)
                        .tag(mode)
                }
            }
            .pickerStyle(.inline)
        } label: {
            Image(systemName: selectedMode.icon)
                .font(.title3)
                .foregroundStyle(Color(hex: 0x00D4AA))
        }
    }

    private var addBlockButton: some View {
        Button {
            if wordBlocks.count < 10 {
                showNewBlockAlert = true
            }
        } label: {
            Image(systemName: "plus.square.fill")
                .font(.title3)
                .foregroundStyle(Color(hex: 0xFF6B35))
        }
        .disabled(wordBlocks.count >= 10)
    }

    // MARK: - Actions

    private func createNewBlock() {
        guard !newBlockName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard wordBlocks.count < 10 else { return }

        let newBlock = WordBlock(
            blockName: newBlockName.trimmingCharacters(in: .whitespacesAndNewlines),
            vocabularyWords: [],
            isActive: true
        )
        modelContext.insert(newBlock)
        newBlockName = ""
    }

    private func deleteBlock(_ block: WordBlock) {
        modelContext.delete(block)
    }
}

// MARK: - Preview

#Preview {
    VocabularyView()
        .environmentObject(IAPManager())
        .modelContainer(for: [WordBlock.self, VocabularyWord.self], inMemory: true)
}
