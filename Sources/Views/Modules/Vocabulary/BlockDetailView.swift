import SwiftUI
import SwiftData

/// Per-block editor — shows block name, list of words with reorder/delete,
/// and toolbar to add words or delete the whole block.
struct BlockDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var translator: TranslatorManager

    let block: WordBlock

    @State private var showRenameAlert = false
    @State private var renameText: String = ""
    @State private var showAddWords = false
    @State private var showDeleteBlockConfirmation = false
    @State private var editMode: EditMode = .inactive

    var body: some View {
        List {
            ForEach(block.vocabularyWords) { word in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(word.nativeWord)
                            .font(.subheadline.bold())
                        Text(word.translatedWord)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    masteryBadge(for: word.masteryLevel)
                }
            }
            .onDelete(perform: deleteWords)
            .onMove(perform: moveWords)

            // Hint footer — appears as the last section's footer.
            Section {
                EmptyView()
            } footer: {
                Text(editMode.isEditing ? "Drag the handles to reorder words" : "Tap Reorder to change word order")
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
            }
        }
        .environment(\.editMode, $editMode)
        .navigationTitle(block.blockName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // SwiftData does NOT guarantee @Relationship array order after save,
            // but wordBlockIndex is the persisted source of truth (re-normalized
            // on every reorder/delete). Re-sort the live array so the List rows,
            // onDelete/onMove offsets, and Audio Mode playback all agree.
            let sorted = block.vocabularyWords.sorted { $0.wordBlockIndex < $1.wordBlockIndex }
            if sorted.map(\.id) != block.vocabularyWords.map(\.id) {
                block.vocabularyWords = sorted
                try? modelContext.save()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation {
                        editMode = editMode.isEditing ? .inactive : .active
                    }
                } label: {
                    Text(editMode.isEditing ? "Done" : "Reorder")
                        .font(.subheadline.bold())
                        .foregroundColor(Color(hex: 0x00D4AA))
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        renameText = block.blockName
                        showRenameAlert = true
                    } label: {
                        Label("Rename Block", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        showDeleteBlockConfirmation = true
                    } label: {
                        Label("Delete Block", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(Color(hex: 0x00D4AA))
                }
            }

            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Spacer()
                    Button {
                        showAddWords = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color(hex: 0x00D4AA))
                    }
                }
            }
        }
        .alert("Rename Block", isPresented: $showRenameAlert) {
            TextField("Block name", text: $renameText)
                .textInputAutocapitalization(.words)
            Button("Cancel", role: .cancel) {}
            Button("Rename") {
                guard !renameText.isEmpty else { return }
                block.blockName = renameText
                try? modelContext.save()
            }
        } message: {
            Text("Enter a new name for this block.")
        }
        .confirmationDialog(
            "Delete Block",
            isPresented: $showDeleteBlockConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete \"\(block.blockName)\"", role: .destructive) {
                HapticPattern.impact.trigger()
                deleteBlock()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete this block and all its words. This action cannot be undone.")
        }
        .sheet(isPresented: $showAddWords) {
            WordInputView(preselectedBlockID: block.id)
        }
    }

    // MARK: - Actions

    private func deleteWords(at offsets: IndexSet) {
        for index in offsets {
            let word = block.vocabularyWords[index]
            modelContext.delete(word)
        }
        block.vocabularyWords.remove(atOffsets: offsets)
        for (idx, word) in block.vocabularyWords.enumerated() {
            word.wordBlockIndex = idx
        }
        try? modelContext.save()
    }

    private func moveWords(from source: IndexSet, to destination: Int) {
        block.vocabularyWords.move(fromOffsets: source, toOffset: destination)
        // Re-normalize wordBlockIndex after reorder.
        for (idx, word) in block.vocabularyWords.enumerated() {
            word.wordBlockIndex = idx
        }
        try? modelContext.save()
    }

    private func deleteBlock() {
        modelContext.delete(block)
        try? modelContext.save()
        dismiss()
    }

    // MARK: - Mastery Badge

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
}
