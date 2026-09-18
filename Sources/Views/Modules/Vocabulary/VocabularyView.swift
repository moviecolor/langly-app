import SwiftUI
import SwiftData

/// Vocabulary module — 3 buttons: Add Word Block, Mix N Match, Audio Mode.
struct VocabularyView: View {
    @EnvironmentObject var iapManager: IAPManager
    @Environment(\.modelContext) private var modelContext
    @Query private var wordBlocks: [WordBlock]
    @Query private var vocabularyWords: [VocabularyWord]
    @Query private var settings: [AppSettings]

    /// Localized chrome string for the user's home language — "Portuguese"
    /// renders Brazilian Portuguese, everything else renders English.
    private func L(_ key: String) -> String {
        Localization.string(key, homeLanguage: settings.first?.homeLanguage)
    }

    @State private var selectedMode: VocabularyMode?
    @State private var showWordInput = false
    @State private var showNewBlockAlert = false
    @State private var newBlockName: String = ""
    @State private var mixAllBlocks: Bool = false
    @State private var selectedBlockForInput: UUID?
    @State private var blockToDelete: WordBlock?
    @State private var showDeleteBlockConfirmation = false
    @State private var showBlockLimitAlert = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // Block summary.
                    blockSummary

                    // Word Mix N Match button.
                    if vocabularyWords.count >= 2 {
                        FeatureCardButton(
                            icon: "gamecontroller.fill",
                            iconGradientColors: [Color(hex: 0xFF6B35), Color(hex: 0xFF8F5E)],
                             title: "Mix N Match",
                            subtitle: L("vocab.mixNMatch.subtitle"),
                            accentColors: [Color(hex: 0xFF6B35).opacity(0.4), Color(hex: 0x00D4AA).opacity(0.3)],
                            action: { selectedMode = .matchMadness }
                        )
                    }

                    // Mix All Blocks button.
                    if wordBlocks.count > 1 {
                        FeatureCardButton(
                            icon: "shuffle",
                            iconGradientColors: [Color(hex: 0x9B59B6), Color(hex: 0x8E44AD)],
                            title: L("vocab.mixAllBlocks"),
                            subtitle: L("vocab.mixAllBlocks.subtitle"),
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
                            title: L("vocab.audioMode"),
                            subtitle: L("vocab.audioMode.subtitle"),
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
                            NavigationLink {
                                BlockDetailView(block: block)
                            } label: {
                                blockCard(block)
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    HapticPattern.impact.trigger()
                                    deleteBlock(block)
                                } label: {
                                    Label(L("vocab.deleteBlock"), systemImage: "trash")
                                }
                            }
                        }

                        // Ghost block suggestion.
                        ghostBlockCard
                    }
                }
                .padding()
            }
        }
        .navigationTitle(L("module.vocabulary"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    selectedBlockForInput = nil
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
            WordInputView(preselectedBlockID: selectedBlockForInput)
        }
        .alert(L("vocab.newBlockTitle"), isPresented: $showNewBlockAlert) {
            TextField(L("vocab.blockName"), text: $newBlockName)
                .textInputAutocapitalization(.words)
            Button(L("vocab.cancel"), role: .cancel) { newBlockName = "" }
            Button(L("vocab.create")) {
                guard !newBlockName.isEmpty else { return }
                if wordBlocks.count >= 10 {
                    showBlockLimitAlert = true
                    newBlockName = ""
                    return
                }
                let block = WordBlock(blockName: newBlockName, vocabularyWords: [], isActive: true)
                modelContext.insert(block)
                try? modelContext.save()
                newBlockName = ""
            }
        } message: {
            Text(L("vocab.newBlockMessage"))
        }
        .alert(L("vocab.blockLimitTitle"), isPresented: $showBlockLimitAlert) {
            Button(L("vocab.ok"), role: .cancel) {}
        } message: {
            Text(L("vocab.blockLimitMessage"))
        }
        .confirmationDialog(
            L("vocab.deleteBlock"),
            isPresented: $showDeleteBlockConfirmation,
            titleVisibility: .visible
        ) {
            if let block = blockToDelete {
                Button(String(format: L("vocab.deleteBlockConfirm"), block.blockName), role: .destructive) {
                    HapticPattern.impact.trigger()
                    deleteBlock(block)
                }
            }
            Button(L("vocab.cancel"), role: .cancel) {}
        } message: {
            Text(L("vocab.deleteBlockMessage"))
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
                    Text(L("vocab.addBlock"))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.primary)

                    Text(L("vocab.addBlock.subtitle"))
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
            summaryCard(icon: "square.stack.3d.down.right.fill", label: L("vocab.blocks"), value: "\(wordBlocks.count)/10")
            summaryCard(icon: "character.book.closed.fill", label: L("vocab.words"), value: "\(vocabularyWords.count)")
            summaryCard(icon: "checkmark.circle.fill", label: L("vocab.mastered"), value: "\(vocabularyWords.filter { $0.masteryLevel == .mastered }.count)")
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
            Text(L("vocab.emptyTitle"))
                .font(.system(size: 16, weight: .bold))
            Text(L("vocab.emptyBody"))
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
                        .foregroundColor(.primary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(format: L("vocab.wordsCount"), activeWords, maxWords))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Text(L("vocab.tapToView"))
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: 0x00D4AA))
                }
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
            } else {
                HStack {
                    Spacer()
                    Text(L("vocab.tapToAddWords"))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary.opacity(0.6))
                    Spacer()
                }
                .padding(.vertical, 8)
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
        .overlay(alignment: .topTrailing) {
            // Quick-delete button overlay.
            Button {
                blockToDelete = block
                showDeleteBlockConfirmation = true
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 22, height: 22)
                    .background(Circle().fill(Color.red.opacity(0.8)))
            }
            .offset(x: 8, y: -8)
            .buttonStyle(.plain)
        }
    }

    // MARK: - Delete Block

    private func deleteBlock(_ block: WordBlock) {
        withAnimation(.spring(duration: 0.3)) {
            modelContext.delete(block)
            try? modelContext.save()
            if selectedBlockForInput == block.id {
                selectedBlockForInput = nil
            }
        }
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

                Text(L("vocab.ghostBlock"))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)

                Text(L("vocab.ghostBlock.subtitle"))
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
    case matchMadness = "Mix N Match"
    case audioMode = "Audio Mode"

    var id: String { rawValue }
}
