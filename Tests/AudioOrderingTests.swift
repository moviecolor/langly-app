import XCTest
import SwiftData
@testable import Langly

/// Unit tests for `AudioModeViewModel.buildPlaybackQueue()` ordering, filtering,
/// and shuffle semantics.
///
/// Queue construction rules under test (see `AudioModeViewModel`):
/// 1. Only blocks whose `id` is in `selectedBlockIDs` participate, iterated in
///    `allBlocks` ARRAY order (the order `loadBlocks` was called with).
/// 2. Within a block, words are played in `wordBlockIndex` ORDER (ascending).
///    `wordBlockIndex` is the persisted source of truth: `BlockDetailView`
///    re-normalizes it to match the user's reorder/delete, and
///    `buildPlaybackQueue()` sorts by it so playback deterministically follows
///    the user's order even if the raw `@Relationship` array order scrambles.
/// 3. Words with an empty `translatedWord` are excluded.
/// 4. When `shuffleEnabled` is true the multiset of words is preserved.
///
/// IMPORTANT SwiftData caveat (verified with a diagnostic probe): to-many
/// `@Relationship` arrays are NOT order-guaranteed by SwiftData — `save()` and
/// refetch can scramble `block.vocabularyWords`. The app defends against this by
/// (a) sorting each block's words by `wordBlockIndex` in `buildPlaybackQueue()`,
/// and (b) re-sorting the live array on `BlockDetailView.onAppear`. These tests
/// therefore PIN each block's array to the authoritative state before generating
/// expectations and assert the index-sorted contract, so they never depend on
/// SwiftData's internal storage ordering and cannot flake.
@MainActor
final class AudioOrderingTests: XCTestCase {

    // MARK: - SwiftData in-memory container helpers

    /// Creates an in-memory `ModelContainer` for the vocabulary models.
    /// Nothing written here touches the on-disk store.
    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([WordBlock.self, VocabularyWord.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    /// Creates a word, inserts it into the container's main context, and returns it.
    private func makeWord(
        in container: ModelContainer,
        native: String,
        translated: String,
        index: Int = 0
    ) -> VocabularyWord {
        let word = VocabularyWord(
            nativeWord: native,
            translatedWord: translated,
            wordBlockIndex: index
        )
        container.mainContext.insert(word)
        return word
    }

    /// Creates a block with the given words, inserts it, saves, and returns it.
    private func makeBlock(
        in container: ModelContainer,
        named name: String,
        words: [VocabularyWord]
    ) throws -> WordBlock {
        let block = WordBlock(blockName: name, vocabularyWords: words, isActive: true)
        container.mainContext.insert(block)
        try container.mainContext.save()
        return block
    }

    /// Pins the block's relationship array to the given authoritative word order.
    ///
    /// This mirrors what the app does at runtime: `BlockDetailView` mutates
    /// `block.vocabularyWords` directly (move/delete) and the array IS the source
    /// of truth for playback. SwiftData does not guarantee relationship order
    /// across `save()`/fetch, so pinning keeps the test focused on
    /// `buildPlaybackQueue()`'s contract rather than SwiftData's backing store.
    private func pinWords(_ words: [VocabularyWord], in block: WordBlock) {
        block.vocabularyWords = words
    }

    /// Creates a view model pre-loaded with the given blocks.
    private func makeViewModel(
        blocks: [WordBlock],
        selectAll: Bool = true
    ) -> AudioModeViewModel {
        let viewModel = AudioModeViewModel()
        viewModel.loadBlocks(blocks)
        if selectAll {
            for block in blocks {
                viewModel.toggleBlockSelection(block.id)
            }
        }
        return viewModel
    }

    /// The words of a block that are eligible for playback (non-empty translation),
    /// in the block's CURRENT array order.
    private func playableWords(of block: WordBlock) -> [VocabularyWord] {
        block.vocabularyWords.filter { !$0.translatedWord.isEmpty }
    }

    // MARK: - a. Unshuffled: block + word order preserved

    func testBuildPlaybackQueue_Unshuffled_PreservesBlockAndWordOrder() throws {
        let container = try makeContainer()
        let b1Words = [
            makeWord(in: container, native: "w1", translated: "t1", index: 0),
            makeWord(in: container, native: "w2", translated: "t2", index: 1),
        ]
        let b2Words = [
            makeWord(in: container, native: "w3", translated: "t3", index: 0),
        ]
        let b3Words = [
            makeWord(in: container, native: "w4", translated: "t4", index: 0),
            makeWord(in: container, native: "w5", translated: "t5", index: 1),
            makeWord(in: container, native: "w6", translated: "t6", index: 2),
        ]
        let b1 = try makeBlock(in: container, named: "B1", words: b1Words)
        let b2 = try makeBlock(in: container, named: "B2", words: b2Words)
        let b3 = try makeBlock(in: container, named: "B3", words: b3Words)
        // Pin authoritative order (the app contract: array order is the truth).
        pinWords(b1Words, in: b1)
        pinWords(b2Words, in: b2)
        pinWords(b3Words, in: b3)
        let orderedBlocks = [b1, b2, b3]
        let viewModel = makeViewModel(blocks: orderedBlocks)

        let queue = viewModel.buildPlaybackQueue()

        // Blocks iterate in allBlocks array order; words in array order within each block.
        XCTAssertEqual(queue.map(\.nativeWord), ["w1", "w2", "w3", "w4", "w5", "w6"])
        XCTAssertEqual(queue.map(\.blockName), ["B1", "B1", "B2", "B3", "B3", "B3"])
        XCTAssertEqual(queue.map(\.blockIndex), [0, 1, 0, 0, 1, 2])
        // Live invariant: queue always mirrors the current arrays, concatenated
        // in allBlocks order — immune to SwiftData relationship-order quirks.
        let expectedNative = orderedBlocks.flatMap { playableWords(of: $0).map(\.nativeWord) }
        XCTAssertEqual(queue.map(\.nativeWord), expectedNative)
        let expectedBlockNames = orderedBlocks.flatMap { block in
            playableWords(of: block).map { _ in block.blockName }
        }
        XCTAssertEqual(queue.map(\.blockName), expectedBlockNames)
    }

    // MARK: - b. Unshuffled: wordBlockIndex order wins (defends SwiftData scramble)

    func testBuildPlaybackQueue_Unshuffled_UsesWordBlockIndexOrder() throws {
        let container = try makeContainer()
        // Simulate a scrambled @Relationship array: array position 0 holds the
        // word with wordBlockIndex 2, etc. Playback must follow the INDEX metadata
        // (the persisted source of truth), not the stale array order.
        let wordA = makeWord(in: container, native: "A", translated: "a", index: 2)
        let wordB = makeWord(in: container, native: "B", translated: "b", index: 0)
        let wordC = makeWord(in: container, native: "C", translated: "c", index: 1)
        let block = try makeBlock(in: container, named: "Block", words: [wordA, wordB, wordC])
        pinWords([wordA, wordB, wordC], in: block)
        let viewModel = makeViewModel(blocks: [block])

        let queue = viewModel.buildPlaybackQueue()

        // Index order wins: B(0) → C(1) → A(2), regardless of array scramble.
        XCTAssertEqual(queue.map(\.nativeWord), ["B", "C", "A"])
        XCTAssertEqual(queue.map(\.blockIndex), [0, 1, 2])

        // Phase 2 — simulate BlockDetailView.moveWords: mutate the array in place
        // (move word at index 2 to the front) and re-normalize indices, exactly
        // like the app does. Playback must now follow the NEW normalized order.
        block.vocabularyWords.move(fromOffsets: IndexSet(integer: 2), toOffset: 0)
        for (idx, word) in block.vocabularyWords.enumerated() {
            word.wordBlockIndex = idx
        }
        let queueAfterReorder = viewModel.buildPlaybackQueue()

        XCTAssertEqual(queueAfterReorder.map(\.nativeWord), ["C", "A", "B"])
        XCTAssertEqual(queueAfterReorder.map(\.blockIndex), [0, 1, 2])
    }

    // MARK: - c. Words with empty translatedWord are excluded

    func testBuildPlaybackQueue_ExcludesWordsWithEmptyTranslatedWord() throws {
        let container = try makeContainer()
        let kept1 = makeWord(in: container, native: "kept1", translated: "t1", index: 0)
        let dropped1 = makeWord(in: container, native: "dropped1", translated: "", index: 1)
        let kept2 = makeWord(in: container, native: "kept2", translated: "t2", index: 2)
        let dropped2 = makeWord(in: container, native: "dropped2", translated: "", index: 3)
        let block = try makeBlock(in: container, named: "Mixed", words: [kept1, dropped1, kept2, dropped2])
        pinWords([kept1, dropped1, kept2, dropped2], in: block)
        let viewModel = makeViewModel(blocks: [block])

        let queue = viewModel.buildPlaybackQueue()

        XCTAssertEqual(queue.map(\.nativeWord), ["kept1", "kept2"])
        XCTAssertFalse(queue.contains { $0.nativeWord.hasPrefix("dropped") },
                       "Words with an empty translatedWord must never enter the queue")
    }

    // MARK: - d. Shuffled queue preserves the word multiset

    func testBuildPlaybackQueue_Shuffled_PreservesWordMultiset() throws {
        let container = try makeContainer()
        let b1Words = [
            makeWord(in: container, native: "alpha", translated: "a"),
            makeWord(in: container, native: "bravo", translated: "b"),
        ]
        let b2Words = [
            makeWord(in: container, native: "charlie", translated: "c"),
            makeWord(in: container, native: "delta", translated: "d"),
            makeWord(in: container, native: "echo", translated: "e"),
        ]
        let b1 = try makeBlock(in: container, named: "B1", words: b1Words)
        let b2 = try makeBlock(in: container, named: "B2", words: b2Words)
        let orderedBlocks = [b1, b2]
        let viewModel = makeViewModel(blocks: orderedBlocks)
        viewModel.shuffleEnabled = true

        let queue = viewModel.buildPlaybackQueue()

        // Same count and same multiset of nativeWords even though order is random.
        let expectedMultiset = orderedBlocks.flatMap { playableWords(of: $0) }.map(\.nativeWord)
        XCTAssertEqual(queue.count, expectedMultiset.count)
        XCTAssertEqual(queue.map(\.nativeWord).sorted(), expectedMultiset.sorted())
        // Every shuffled word must still be attributed to its original block.
        XCTAssertEqual(Set(queue.map(\.blockName)), ["B1", "B2"])
    }

    // MARK: - e. Empty selection → empty queue, startPlayback no-ops

    func testBuildPlaybackQueue_EmptySelection_EmptyQueueAndStartPlaybackNoOps() throws {
        let container = try makeContainer()
        let block = try makeBlock(in: container, named: "B1", words: [
            makeWord(in: container, native: "w", translated: "t"),
        ])
        let viewModel = makeViewModel(blocks: [block], selectAll: false)

        // Nothing selected yet — queue is empty.
        XCTAssertTrue(viewModel.buildPlaybackQueue().isEmpty)

        // startPlayback() with an empty queue must no-op: stay stopped, no progress.
        viewModel.startPlayback()
        XCTAssertEqual(viewModel.playbackState, .stopped)
        XCTAssertEqual(viewModel.totalWordsInQueue, 0)
        XCTAssertNil(viewModel.currentWord)

        // Select → non-empty; deselect → empty again.
        viewModel.toggleBlockSelection(block.id)
        XCTAssertEqual(viewModel.buildPlaybackQueue().count, 1)
        viewModel.toggleBlockSelection(block.id)
        XCTAssertTrue(viewModel.buildPlaybackQueue().isEmpty)
    }

    // MARK: - f. Partial selection still follows allBlocks array order

    func testBuildPlaybackQueue_PartialSelection_FollowsAllBlocksArrayOrder() throws {
        let container = try makeContainer()
        let b1 = try makeBlock(in: container, named: "B1", words: [
            makeWord(in: container, native: "one", translated: "t1"),
        ])
        let b2 = try makeBlock(in: container, named: "B2", words: [
            makeWord(in: container, native: "two", translated: "t2"),
        ])
        let b3 = try makeBlock(in: container, named: "B3", words: [
            makeWord(in: container, native: "three", translated: "t3"),
        ])
        let viewModel = makeViewModel(blocks: [b1, b2, b3], selectAll: false)
        // Select B3 FIRST, then B1 — Set insertion order must NOT affect the queue;
        // allBlocks array order governs.
        viewModel.toggleBlockSelection(b3.id)
        viewModel.toggleBlockSelection(b1.id)

        let queue = viewModel.buildPlaybackQueue()

        XCTAssertEqual(queue.map(\.blockName), ["B1", "B3"])
        XCTAssertEqual(queue.map(\.nativeWord), ["one", "three"])
    }
}