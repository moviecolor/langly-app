import SwiftUI
import SwiftData
import UIKit

/// Word input view — add new vocabulary words with auto-translation or manual entry.
/// User types a native-language word, the app translates it via Apple's Translation framework,
/// or the user manually enters both the native word and its translation.
struct WordInputView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var translator: TranslatorManager
    @Query private var wordBlocks: [WordBlock]
    @Query private var vocabularyWords: [VocabularyWord]
    @Query private var trackers: [StreakTracker]
    @Query private var analytics: [LocalAnalytics]

    /// Optional block ID to pre-select when opened from a block card.
    let preselectedBlockID: UUID?

    /// Input field for the native-language word.
    @State private var nativeWordInput: String = ""

    /// The translated word (populated by auto-translate or manual entry).
    @State private var translatedWord: String = ""

    /// Whether a translation is in progress.
    @State private var isTranslating: Bool = false

    /// Whether translation was successful.
    @State private var translationStatus: TranslationStatus = .idle

    /// The selected block to add the word to.
    @State private var selectedBlockID: UUID?

    /// Whether the word list is expanded.
    @State private var showWordList: Bool = true

    /// Filter for the word list.
    @State private var wordListFilter: MasteryLevel? = nil

    /// Alert state for "no block selected" warning.
    @State private var showNoBlockAlert: Bool = false

    /// Success feedback state — shows a brief "Saved!" toast.
    @State private var showSaveFeedback: Bool = false

    /// Error feedback state — shows a brief save error message.
    @State private var showSaveError: Bool = false

    init(preselectedBlockID: UUID? = nil) {
        self.preselectedBlockID = preselectedBlockID
    }

    enum TranslationStatus {
        case idle
        case translating
        case success
        case failed
    }

    var body: some View {
        NavigationStack {
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

                ScrollView {
                    VStack(spacing: 20) {
                        // Translation input section.
                        translationSection

                        // Block selector.
                        blockSelectorSection

                        // Save button.
                        saveButton

                        // Word list.
                        wordListSection
                    }
                    .padding()
                }

                // Success feedback toast.
                if showSaveFeedback {
                    VStack {
                        Spacer()
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.white)
                            Text("Saved!")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color(hex: 0x00D4AA))
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                        .padding(.bottom, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle("Add Words")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("No Block Selected", isPresented: $showNoBlockAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please select a block first before saving a word.")
            }
            .alert("Save Failed", isPresented: $showSaveError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Could not save the word. Please try again.")
            }
            .task {
                // Pre-select block if opened from a block card.
                if let blockID = preselectedBlockID {
                    selectedBlockID = blockID
                }
            }
        }
    }

    // MARK: - Translation Section

    private var translationSection: some View {
        VStack(spacing: 16) {
            // Native word input (English).
            nativeWordInputField

            // Translate button — auto-fills the Portuguese field.
            translateButton

            // Translation status message.
            if translationStatus == .failed {
                Text("Translation not found — type the word manually below.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Translated word input (Portuguese) — always visible, always editable.
            translatedWordInputField
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appSurface.opacity(0.6))
        )
    }

    // MARK: - Native Word Input Field

    private var nativeWordInputField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "globe")
                    .font(.caption)
                    .foregroundColor(Color(hex: 0x00D4AA))
                Text("English")
                    .font(.subheadline.bold())
                    .foregroundColor(.secondary)
            }

            TextField("Type a word (e.g., banana)", text: $nativeWordInput)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .font(.title3)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.appSurface.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: 0x00D4AA).opacity(0.3), lineWidth: 1)
                        )
                )
                .onSubmit {
                    Task { await translateWord() }
                }
        }
    }

    // MARK: - Translate Button

    private var translateButton: some View {
        Button {
            Task { await translateWord() }
        } label: {
            HStack {
                if isTranslating {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "arrow.left.arrow.right")
                }

                Text(isTranslating ? "Translating..." : "Auto-Translate")
                    .font(.subheadline.bold())
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                nativeWordInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isTranslating
                    ? Color(hex: 0x00D4AA).opacity(0.4)
                    : Color(hex: 0x00D4AA)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .disabled(nativeWordInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isTranslating)
    }

    // MARK: - Translated Word Input Field (always visible, always editable)

    private var translatedWordInputField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "pencil")
                    .font(.caption)
                    .foregroundColor(Color(hex: 0xFF6B35))
                Text("Portuguese")
                    .font(.subheadline.bold())
                    .foregroundColor(.secondary)

                Spacer()

                if !translatedWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                        Text("Ready")
                            .font(.caption)
                    }
                    .foregroundColor(Color(hex: 0x00D4AA))
                }
            }

            TextField("Type the translation (e.g., banana)", text: $translatedWord)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .font(.title3)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.appSurface.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    translatedWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                        ? Color(hex: 0xFF6B35).opacity(0.3)
                                        : Color(hex: 0x00D4AA).opacity(0.5),
                                    lineWidth: 1
                                )
                        )
                )

            Text("Type the word yourself, or tap Auto-Translate above")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.7))
        }
    }

    // MARK: - Block Selector

    private var blockSelectorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add to Block")
                .font(.subheadline.bold())
                .foregroundColor(.secondary)

            if wordBlocks.isEmpty {
                Text("No blocks available. Create a block first.")
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 12)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(wordBlocks) { block in
                            blockChip(block)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appSurface.opacity(0.6))
        )
    }

    private func blockChip(_ block: WordBlock) -> some View {
        let isSelected = selectedBlockID == block.id
        let wordCount = block.vocabularyWords.count
        let isFull = wordCount >= 15

        return Button {
            selectedBlockID = block.id
        } label: {
            VStack(spacing: 4) {
                Text(block.blockName)
                    .font(.subheadline.bold())
                    .foregroundColor(isSelected ? .white : .primary)

                Text(isFull ? "Full" : "\(wordCount)/15")
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        isSelected
                            ? Color(hex: 0x00D4AA)
                            : Color.appSurface.opacity(0.8)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isSelected ? Color(hex: 0x00D4AA) : Color(hex: 0x00D4AA).opacity(0.3),
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(isFull)
        .opacity(isFull ? 0.5 : 1)
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button {
            saveWord()
        } label: {
            HStack {
                Image(systemName: "square.and.arrow.down.fill")
                Text("Save Word")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                canSaveWord ? Color(hex: 0xFF6B35) : Color(hex: 0xFF6B35).opacity(0.4)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .disabled(!canSaveWord)
        .overlay(alignment: .bottom) {
            // "No block selected" hint when user has filled in words but hasn't selected a block.
            if !nativeWordInput.isEmpty && !translatedWord.isEmpty && selectedBlockID == nil {
                Text("Select a block above to save")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 4)
            }
        }
    }

    private var canSaveWord: Bool {
        !nativeWordInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !translatedWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && selectedBlockID != nil
    }

    // MARK: - Word List Section

    private var wordListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Word List (\(filteredWords.count))")
                    .font(.headline)
                    .foregroundStyle(Color(hex: 0x00D4AA))

                Spacer()

                Button {
                    showWordList.toggle()
                } label: {
                    Image(systemName: showWordList ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
            }

            if showWordList {
                // Mastery filter.
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        filterChip(label: "All", level: nil)
                        ForEach(MasteryLevel.allCases, id: \.self) { level in
                            filterChip(label: level.rawValue.capitalized, level: level)
                        }
                    }
                }

                // Words.
                if filteredWords.isEmpty {
                    Text("No words yet.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                } else {
                    ForEach(filteredWords) { word in
                        wordRow(word)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appSurface.opacity(0.6))
        )
    }

    private func filterChip(label: String, level: MasteryLevel?) -> some View {
        let isSelected = wordListFilter == level

        return Button {
            wordListFilter = level
        } label: {
            Text(label)
                .font(.caption.bold())
                .foregroundColor(isSelected ? .white : .secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color(hex: 0x00D4AA) : Color.appSurface.opacity(0.8))
                )
        }
        .buttonStyle(.plain)
    }

    private func wordRow(_ word: VocabularyWord) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(word.nativeWord)
                    .font(.subheadline.bold())

                Text(word.translatedWord)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Mastery badge.
            masteryBadge(for: word.masteryLevel)

            // Delete button.
            Button {
                deleteWord(word)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red.opacity(0.6))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
    }

    private func masteryBadge(for level: MasteryLevel) -> some View {
        let (color, label) = masteryInfo(for: level)

        return Text(label)
            .font(.caption.bold())
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(color.opacity(0.15))
            )
    }

    private func masteryInfo(for level: MasteryLevel) -> (color: Color, label: String) {
        switch level {
        case .unlearned:
            return (.secondary, "New")
        case .learning:
            return (Color(hex: 0xFF6B35), "Learning")
        case .mastered:
            return (Color(hex: 0x00D4AA), "Mastered")
        }
    }

    // MARK: - Actions

    /// Translates the current native word input.
    private func translateWord() async {
        let trimmed = nativeWordInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        isTranslating = true
        translationStatus = .translating

        let result = await translator.translate(trimmed)

        await MainActor.run {
            isTranslating = false
            if result != trimmed {
                translatedWord = result
                translationStatus = .success
            } else {
                translationStatus = .failed
            }
        }
    }

    /// Saves the current word to the selected block.
    private func saveWord() {
        guard let blockID = selectedBlockID,
              let block = wordBlocks.first(where: { $0.id == blockID }) else {
            showNoBlockAlert = true
            return
        }

        guard block.vocabularyWords.count < 15 else { return }

        let trimmedNative = nativeWordInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTranslated = translatedWord.trimmingCharacters(in: .whitespacesAndNewlines)

        let newWord = VocabularyWord(
            nativeWord: trimmedNative,
            translatedWord: trimmedTranslated,
            masteryLevel: .unlearned,
            wordBlockIndex: block.vocabularyWords.count,
            dateAdded: .now
        )

        modelContext.insert(newWord)
        block.vocabularyWords.append(newWord)

        // Explicitly save the context so SwiftData persists the new word.
        do {
            try modelContext.save()
        } catch {
            print("[WordInputView] Failed to save word: \(error)")
            showSaveError = true
            return
        }

        // Track streak progress.
        if let tracker = trackers.first {
            tracker.totalWordsReviewed += 1
            tracker.recordPractice()
            try? modelContext.save()
        }

        // Track analytics.
        if let stats = analytics.first {
            stats.trackWordAdded()
            stats.trackWordsReviewed(count: 1)
            try? modelContext.save()
        }

        // Haptic feedback for successful save.
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Reset input fields.
        nativeWordInput = ""
        translatedWord = ""
        translationStatus = .idle

        // Show brief success feedback.
        showSaveFeedback = true
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            showSaveFeedback = false
        }
    }

    /// Deletes a word from its block and the context.
    private func deleteWord(_ word: VocabularyWord) {
        modelContext.delete(word)
    }

    // MARK: - Computed

    private var filteredWords: [VocabularyWord] {
        if let filter = wordListFilter {
            return vocabularyWords.filter { $0.masteryLevel == filter }
        }
        return vocabularyWords
    }
}

// MARK: - Preview

#Preview {
    WordInputView(preselectedBlockID: nil)
        .environmentObject(TranslatorManager())
        .modelContainer(for: [WordBlock.self, VocabularyWord.self], inMemory: true)
}
