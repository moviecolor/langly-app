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

    /// Whether a wrong-match animation should play.
    @Published var showWrongMatch: Bool = false

    /// Total number of matches made in this session.
    @Published var totalMatches: Int = 0

    /// Total number of wrong attempts in this session.
    @Published var wrongAttempts: Int = 0

    // MARK: - Properties

    /// All available vocabulary words from active blocks.
    private var allWords: [VocabularyWord] = []

    /// Words that have already been matched and removed from the pool.
    private var matchedWords: Set<String> = []

    /// Timer for the countdown.
    private var timer: Timer?

    /// The game duration in seconds (1 min 45 sec).
    static let gameDurationSeconds: Int = 105

    // MARK: - Public API

    /// Loads words from the provided WordBlocks and initializes the game board.
    func loadWords(from blocks: [WordBlock]) {
        let activeBlocks = blocks.filter { $0.isActive }
        allWords = activeBlocks.flatMap { $0.vocabularyWords }
            .filter { !$0.translatedWord.isEmpty }
    }

    /// Starts a new game session.
    func startGame() {
        guard !allWords.isEmpty else { return }

        gameState = .playing
        score = 0
        totalMatches = 0
        wrongAttempts = 0
        timeRemaining = Self.gameDurationSeconds
        matchedWords.removeAll()
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

    /// Stops the game and returns to idle state.
    func stopGame() {
        gameState = .idle
        timer?.invalidate()
        timer = nil
        selectedLeft = nil
        selectedRight = nil
        showWrongMatch = false
    }

    /// Restarts the game with a fresh board.
    func restartGame() {
        stopGame()
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

    // MARK: - Private

    /// Deals new words into both columns from the available pool.
    private func dealNewWords() {
        let availableWords = allWords.filter { !matchedWords.contains($0.nativeWord.lowercased()) }

        guard !availableWords.isEmpty else {
            // All words matched — end the game.
            endGame()
            return
        }

        // Select up to 8 words for this round.
        let count = min(8, availableWords.count)
        let shuffled = availableWords.shuffled()
        let roundWords = Array(shuffled.prefix(count))

        // Mark these words as "in play" to avoid duplicates.
        for word in roundWords {
            matchedWords.insert(word.nativeWord.lowercased())
        }

        // Create MatchWord instances.
        let matchWords = roundWords.map {
            MatchWord(
                nativeWord: $0.nativeWord,
                translatedWord: $0.translatedWord,
                blockIndex: $0.wordBlockIndex
            )
        }

        if isJumbleEnabled {
            // In jumble mode, randomly assign native or translated to each column.
            leftColumn = matchWords.shuffled().map { word in
                Bool.random()
                    ? MatchWord(nativeWord: word.nativeWord, translatedWord: word.translatedWord, blockIndex: word.blockIndex)
                    : MatchWord(nativeWord: word.translatedWord, translatedWord: word.nativeWord, blockIndex: word.blockIndex)
            }
            rightColumn = matchWords.shuffled().map { word in
                Bool.random()
                    ? MatchWord(nativeWord: word.translatedWord, translatedWord: word.nativeWord, blockIndex: word.blockIndex)
                    : MatchWord(nativeWord: word.nativeWord, translatedWord: word.translatedWord, blockIndex: word.blockIndex)
            }
        } else {
            // Normal mode: left = native, right = translated.
            leftColumn = matchWords.shuffled()
            rightColumn = matchWords.shuffled()
        }

        selectedLeft = nil
        selectedRight = nil
    }

    /// Checks whether the selected left and right words form a valid match.
    private func checkMatch(left: MatchWord, right: MatchWord) {
        let isMatch = left.nativeWord.lowercased() == right.translatedWord.lowercased()
            || left.translatedWord.lowercased() == right.nativeWord.lowercased()

        if isMatch {
            // Correct match!
            score += 1
            totalMatches += 1

            // Remove matched words from columns.
            leftColumn.removeAll { $0.id == left.id }
            rightColumn.removeAll { $0.id == right.id }

            selectedLeft = nil
            selectedRight = nil

            // Deal replacements if there are still words available.
            let availableCount = allWords.filter { !matchedWords.contains($0.nativeWord.lowercased()) }.count
            if availableCount > 0 {
                dealReplacements()
            } else if leftColumn.isEmpty && rightColumn.isEmpty {
                // All words matched — end game.
                endGame()
            }
        } else {
            // Wrong match.
            wrongAttempts += 1
            showWrongMatch = true

            // Brief delay to show the wrong-match feedback.
            Task {
                try? await Task.sleep(for: .milliseconds(500))
                selectedLeft = nil
                selectedRight = nil
                showWrongMatch = false
            }
        }
    }

    /// Deals replacement words for matched pairs.
    private func dealReplacements() {
        let availableWords = allWords.filter { !matchedWords.contains($0.nativeWord.lowercased()) }

        guard !availableWords.isEmpty else { return }

        // Determine how many slots need filling.
        let slotsNeeded = 8 - leftColumn.count
        let count = min(slotsNeeded, availableWords.count)
        let newWords = Array(availableWords.shuffled().prefix(count))

        for word in newWords {
            matchedWords.insert(word.nativeWord.lowercased())
        }

        let matchWords = newWords.map {
            MatchWord(
                nativeWord: $0.nativeWord,
                translatedWord: $0.translatedWord,
                blockIndex: $0.wordBlockIndex
            )
        }

        if isJumbleEnabled {
            for word in matchWords {
                if Bool.random() {
                    leftColumn.append(word)
                    rightColumn.append(
                        MatchWord(nativeWord: word.translatedWord, translatedWord: word.nativeWord, blockIndex: word.blockIndex)
                    )
                } else {
                    leftColumn.append(
                        MatchWord(nativeWord: word.translatedWord, translatedWord: word.nativeWord, blockIndex: word.blockIndex)
                    )
                    rightColumn.append(word)
                }
            }
        } else {
            leftColumn.append(contentsOf: matchWords.shuffled())
            rightColumn.append(contentsOf: matchWords.shuffled())
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
