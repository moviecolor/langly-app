import Foundation
import SwiftData

/// Game states for Match Madness.
enum MatchMadnessState: String {
    case idle
    case playing
    case paused
    case complete
}

/// Represents a single word option displayed in the game grid.
struct MatchWord: Identifiable, Equatable, Hashable {
    let id = UUID()
    let nativeWord: String
    let translatedWord: String
    let blockIndex: Int

    /// Unique key for matching native ↔ translated pairs.
    var matchKey: String { nativeWord.lowercased() }
}

/// ViewModel for the Match Madness game mode.
/// Manages 8 English words (left) + 8 Portuguese words (right), matching by selection.
@MainActor
final class MatchMadnessViewModel: ObservableObject {
    // MARK: - Published State

    /// Current game state.
    @Published var gameState: MatchMadnessState = .idle

    /// Words displayed in the left column.
    @Published var leftColumn: [MatchWord] = []

    /// Words displayed in the right column.
    @Published var rightColumn: [MatchWord] = []

    /// Currently selected word from the left column (nil if none).
    @Published var selectedLeft: MatchWord?

    /// Currently selected word from the right column (nil if none).
    @Published var selectedRight: MatchWord?

    /// Remaining time in seconds.
    @Published var timeRemaining: Int = 105

    /// Current score (number of correct matches).
    @Published var score: Int = 0

    /// Whether jumble mode is enabled (either language can appear in either column).
    @Published var isJumbleEnabled: Bool = false

    /// Currently selected block name for the game.
    @Published var selectedBlockName: String?

    /// Set of active block names included in the current game.
    @Published var activeBlockNames: Set<String> = []

    /// Whether a wrong-match animation should play.
    @Published var showWrongMatch: Bool = false

    /// Total number of matches made in this session.
    @Published var totalMatches: Int = 0

    /// Total number of wrong attempts in this session.
    @Published var wrongAttempts: Int = 0

    // MARK: - Properties

    /// All available vocabulary words from active blocks.
    private var allWords: [VocabularyWord] = []

    /// Reserve pool of words not yet on the board.
    private var reserveWords: [MatchWord] = []

    /// Timer for the countdown.
    private var timer: Timer?

    /// The game duration in seconds (1 min 45 sec).
    static let gameDurationSeconds: Int = 105

    // MARK: - Public API

    /// Loads words from the provided WordBlocks and initializes the game board.
    func loadWords(from blocks: [WordBlock], blockName: String? = nil) {
        let targetBlock: WordBlock?
        if let blockName = blockName {
            targetBlock = blocks.first { $0.blockName == blockName && $0.isActive }
        } else {
            // Default to first active block.
            targetBlock = blocks.first { $0.isActive }
        }
        allWords = targetBlock?.vocabularyWords
            .filter { !$0.translatedWord.isEmpty } ?? []
        selectedBlockName = targetBlock?.blockName
        if let name = targetBlock?.blockName {
            activeBlockNames = [name]
        }
    }

    /// Loads words from ALL active blocks (mix mode).
    func loadAllBlocks(from blocks: [WordBlock]) {
        let activeBlocks = blocks.filter { $0.isActive }
        allWords = activeBlocks.flatMap { $0.vocabularyWords }
            .filter { !$0.translatedWord.isEmpty }
        selectedBlockName = "All Blocks"
        activeBlockNames = Set(activeBlocks.map { $0.blockName })
    }

    /// Toggles a block on or off and rebuilds the word pool from all active blocks.
    func toggleBlock(_ blockName: String, blocks: [WordBlock]) {
        if activeBlockNames.contains(blockName) {
            activeBlockNames.remove(blockName)
        } else {
            activeBlockNames.insert(blockName)
        }

        // Rebuild allWords from currently active blocks.
        let activeBlocks = blocks.filter { activeBlockNames.contains($0.blockName) && $0.isActive }
        allWords = activeBlocks.flatMap { $0.vocabularyWords }
            .filter { !$0.translatedWord.isEmpty }

        if activeBlockNames.isEmpty {
            selectedBlockName = nil
        } else if activeBlockNames.count == blocks.filter({ $0.isActive }).count {
            selectedBlockName = "All Blocks"
        } else {
            selectedBlockName = activeBlockNames.sorted().joined(separator: ", ")
        }

        // If game is playing or paused, restart with the new word set.
        if gameState == .playing || gameState == .paused {
            stopGame()
            startGame()
        }
    }

    /// Starts a new game session.
    func startGame() {
        guard !allWords.isEmpty else { return }

        gameState = .playing
        score = 0
        totalMatches = 0
        wrongAttempts = 0
        timeRemaining = Self.gameDurationSeconds
        selectedLeft = nil
        selectedRight = nil
        showWrongMatch = false

        dealNewWords()
        startTimer()
    }

    /// Pauses the current game.
    func pauseGame() {
        guard gameState == .playing else { return }
        gameState = .paused
        timer?.invalidate()
        timer = nil
    }

    /// Resumes a paused game.
    func resumeGame() {
        guard gameState == .paused else { return }
        gameState = .playing
        startTimer()
    }

    /// Stops the game and transitions to complete state (shows score overlay).
    func stopGame() {
        gameState = .complete
        timer?.invalidate()
        timer = nil
        selectedLeft = nil
        selectedRight = nil
        showWrongMatch = false
    }

    /// Resets the game to idle without triggering the complete overlay.
    /// Used internally by restartGame to avoid re-showing the overlay.
    func resetToIdle() {
        gameState = .idle
        timer?.invalidate()
        timer = nil
        selectedLeft = nil
        selectedRight = nil
        showWrongMatch = false
    }

    /// Restarts the game with a fresh board.
    func restartGame() {
        resetToIdle()
        startGame()
    }

    /// Handles selection of a word from the left column.
    func selectLeftWord(_ word: MatchWord) {
        guard gameState == .playing else { return }

        if selectedLeft?.id == word.id {
            selectedLeft = nil
            return
        }

        selectedLeft = word

        // Check for a match if both columns have selections.
        if let rightWord = selectedRight {
            checkMatch(left: word, right: rightWord)
        }
    }

    /// Handles selection of a word from the right column.
    func selectRightWord(_ word: MatchWord) {
        guard gameState == .playing else { return }

        if selectedRight?.id == word.id {
            selectedRight = nil
            return
        }

        selectedRight = word

        // Check for a match if both columns have selections.
        if let leftWord = selectedLeft {
            checkMatch(left: leftWord, right: word)
        }
    }

    /// Toggles jumble mode and re-deals the board if the game is active.
    func toggleJumble() {
        isJumbleEnabled.toggle()
        if gameState == .playing || gameState == .paused {
            dealNewWords()
        }
    }

    /// Switches to a different block and restarts the game.
    func switchBlock(to blockName: String?, from blocks: [WordBlock]) {
        if let blockName = blockName {
            loadWords(from: blocks, blockName: blockName)
        } else {
            loadAllBlocks(from: blocks)
        }
        if gameState == .playing || gameState == .paused || gameState == .complete {
            startGame()
        }
    }

    // MARK: - Private

    static let maxBoardWords = 8

    /// Randomly swaps nativeWord ↔ translatedWord with 50% probability for jumble mode.
    private func flipWord(_ word: MatchWord) -> MatchWord {
        Bool.random()
            ? word
            : MatchWord(nativeWord: word.translatedWord, translatedWord: word.nativeWord, blockIndex: word.blockIndex)
    }

    /// Deterministically swaps nativeWord ↔ translatedWord (always flips).
    private func forceFlip(_ word: MatchWord) -> MatchWord {
        MatchWord(nativeWord: word.translatedWord, translatedWord: word.nativeWord, blockIndex: word.blockIndex)
    }

    /// Deals words into both columns. Shows up to 8, rest go to reserve.
    private func dealNewWords() {
        let shuffled = allWords.shuffled()

        guard !shuffled.isEmpty else {
            endGame()
            return
        }

        let boardCount = min(Self.maxBoardWords, shuffled.count)
        let boardWords = Array(shuffled.prefix(boardCount))
        let reservePool = Array(shuffled.dropFirst(boardCount))

        // Create MatchWord instances for the board.
        let matchWords = boardWords.map {
            MatchWord(
                nativeWord: $0.nativeWord,
                translatedWord: $0.translatedWord,
                blockIndex: $0.wordBlockIndex
            )
        }

        // Create MatchWord instances for the reserve.
        reserveWords = reservePool.map {
            MatchWord(
                nativeWord: $0.nativeWord,
                translatedWord: $0.translatedWord,
                blockIndex: $0.wordBlockIndex
            )
        }

        if isJumbleEnabled {
            // JUMBLE MODE: all words in both columns. Each word is randomly
            // either "normal" (English left, Portuguese right) or "flipped"
            // (Portuguese left, English right). Both columns get the SAME
            // flip decision so they always show DIFFERENT languages.
            let shouldFlip = matchWords.map { _ in Bool.random() }

            leftColumn = zip(matchWords, shouldFlip).map { word, flip in
                flip ? forceFlip(word) : word
            }.shuffled()

            rightColumn = zip(matchWords, shouldFlip).map { word, flip in
                flip ? forceFlip(word) : word
            }.shuffled()
        } else {
            // NORMAL MODE: all words in both columns (native on left, translated on right).
            leftColumn = matchWords.shuffled()
            // Right column: shuffled so no translation sits directly across from its pair.
            rightColumn = shuffledRight(for: leftColumn, from: matchWords)
        }

        selectedLeft = nil
        selectedRight = nil
    }

    /// Shuffles words for the right column so no index has matching blockIndex with left.
    /// Used in normal (non-jumble) mode only.
    private func shuffledRight(for left: [MatchWord], from words: [MatchWord]) -> [MatchWord] {
        var right = words.shuffled()
        var attempts = 0
        while attempts < 100 {
            var conflict = false
            for i in 0..<min(left.count, right.count) {
                if left[i].blockIndex == right[i].blockIndex {
                    conflict = true
                    break
                }
            }
            if !conflict { break }
            // Swap two random positions to break the conflict.
            if right.count >= 2 {
                let a = Int.random(in: 0..<right.count)
                var b = Int.random(in: 0..<right.count)
                while b == a { b = Int.random(in: 0..<right.count) }
                right.swapAt(a, b)
            }
            attempts += 1
        }
        return right
    }

    /// Adds reserve words to replace a matched pair removed from the board.
    private func addReserveWords() {
        guard !reserveWords.isEmpty else { return }

        if isJumbleEnabled {
            // JUMBLE MODE: pop ONE word, add to both columns with the SAME flip.
            let word = reserveWords.removeFirst()
            let flip = Bool.random()
            let leftWord = flip ? forceFlip(word) : word
            let rightWord = flip ? forceFlip(word) : word
            let leftPos = leftColumn.isEmpty ? 0 : Int.random(in: 0...leftColumn.count)
            leftColumn.insert(leftWord, at: leftPos)

            // Insert into right column (same flip, different position).
            var rightPos = rightColumn.isEmpty ? 0 : Int.random(in: 0...rightColumn.count)
            var attempts = 0
            while attempts < 30 {
                let safePos = min(rightPos, rightColumn.count)
                let conflict = safePos < rightColumn.count && leftPos < leftColumn.count
                    && leftColumn[leftPos].blockIndex == rightColumn[safePos].blockIndex
                if !conflict { break }
                rightPos = rightColumn.isEmpty ? 0 : Int.random(in: 0...rightColumn.count)
                attempts += 1
            }
            rightColumn.insert(rightWord, at: min(rightPos, rightColumn.count))
        } else {
            // NORMAL MODE: same word inserted into both columns.
            let word = reserveWords.removeFirst()

            let leftPos = leftColumn.isEmpty ? 0 : Int.random(in: 0...leftColumn.count)
            leftColumn.insert(word, at: leftPos)

            var rightPos = rightColumn.isEmpty ? 0 : Int.random(in: 0...rightColumn.count)
            var attempts = 0
            while attempts < 30 {
                let safePos = min(rightPos, rightColumn.count)
                let conflict = safePos < rightColumn.count && leftPos < leftColumn.count
                    && leftColumn[leftPos].blockIndex == rightColumn[safePos].blockIndex
                if !conflict { break }
                rightPos = rightColumn.isEmpty ? 0 : Int.random(in: 0...rightColumn.count)
                attempts += 1
            }
            rightColumn.insert(word, at: min(rightPos, rightColumn.count))
        }
    }

    /// Checks whether the selected left and right words form a valid match.
    private func checkMatch(left: MatchWord, right: MatchWord) {
        // Match by blockIndex — same vocabulary word selected from both columns.
        let isMatch = left.blockIndex == right.blockIndex

        if isMatch {
            // Correct match! Score = 1 per pair.
            score += 1
            totalMatches += 1

            // Remove matched words from both columns.
            leftColumn.removeAll { $0.id == left.id }
            rightColumn.removeAll { $0.id == right.id }

            selectedLeft = nil
            selectedRight = nil

            // If reserve has words, replace the matched pair.
            if !reserveWords.isEmpty {
                addReserveWords()
            }

            // Game complete when board is empty.
            if leftColumn.isEmpty && rightColumn.isEmpty {
                endGame()
            }
        } else {
            // Wrong match.
            wrongAttempts += 1
            showWrongMatch = true

            Task {
                try? await Task.sleep(for: .milliseconds(500))
                selectedLeft = nil
                selectedRight = nil
                showWrongMatch = false
            }
        }
    }

    /// Starts the countdown timer.
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.timeRemaining -= 1
                if self.timeRemaining <= 0 {
                    self.endGame()
                }
            }
        }
    }

    /// Ends the game and transitions to the complete state.
    private func endGame() {
        gameState = .complete
        timer?.invalidate()
        timer = nil
        selectedLeft = nil
        selectedRight = nil
    }
}
