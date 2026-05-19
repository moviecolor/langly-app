import Foundation
import SwiftData
import AVFoundation

/// Playback states for Audio Mode.
enum AudioPlaybackState: String {
    case stopped
    case playing
    case paused
}

/// Represents a word in the audio playback queue.
struct AudioWord: Identifiable, Equatable {
    let id = UUID()
    let nativeWord: String
    let translatedWord: String
    let blockIndex: Int
    let blockName: String
}

/// ViewModel for the Audio Mode — continuous word playback with TTS.
/// Plays English word once, then target-language word N times, with configurable gaps.
@MainActor
final class AudioModeViewModel: NSObject, ObservableObject {
    // MARK: - Published State

    /// Current playback state.
    @Published var playbackState: AudioPlaybackState = .stopped

    /// The word currently being spoken.
    @Published var currentWord: AudioWord?

    /// Which utterance is currently playing ("native" or "translated").
    @Published var currentUtteranceType: String = ""

    /// Progress: current word index out of total words in the queue.
    @Published var progressIndex: Int = 0

    /// Total number of words in the current playback queue.
    @Published var totalWordsInQueue: Int = 0

    /// Selected block IDs for playback.
    @Published var selectedBlockIDs: Set<UUID> = []

    /// Number of repetitions for the translated word (1–9).
    @Published var repetitions: Int = 1

    /// Gap in seconds between words.
    @Published var gapSeconds: Double = 1.0

    // MARK: - Properties

    /// The speech synthesizer for TTS playback.
    private let synthesizer = AVSpeechSynthesizer()

    /// All available word blocks.
    private var allBlocks: [WordBlock] = []

    /// The flattened playback queue of AudioWords.
    private var playbackQueue: [AudioWord] = []

    /// Current index in the playback queue.
    private var queueIndex: Int = 0

    /// Whether playback was manually stopped (vs. naturally finishing).
    private var wasManuallyStopped: Bool = false

    /// Whether to loop the entire queue.
    private var loopEnabled: Bool = true

    /// Pending utterance sequence for the current word pair.
    private var pendingUtterances: [(text: String, language: String, label: String)] = []

    /// Current index within the pending utterance sequence.
    private var utteranceIndex: Int = 0

    // MARK: - Initialization

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    // MARK: - Public API

    /// Loads all word blocks from the query.
    func loadBlocks(_ blocks: [WordBlock]) {
        allBlocks = blocks
    }

    /// Toggles selection of a word block.
    func toggleBlockSelection(_ blockID: UUID) {
        if selectedBlockIDs.contains(blockID) {
            selectedBlockIDs.remove(blockID)
        } else {
            selectedBlockIDs.insert(blockID)
        }
    }

    /// Selects all active blocks.
    func selectAllActiveBlocks() {
        selectedBlockIDs = Set(allBlocks.filter { $0.isActive }.map { $0.id })
    }

    /// Clears all block selections.
    func clearSelection() {
        selectedBlockIDs.removeAll()
    }

    /// Starts audio playback of the selected blocks.
    func startPlayback() {
        // Build the playback queue from selected blocks.
        playbackQueue = buildPlaybackQueue()
        guard !playbackQueue.isEmpty else { return }

        wasManuallyStopped = false
        queueIndex = 0
        totalWordsInQueue = playbackQueue.count
        progressIndex = 0
        playbackState = .playing

        // Start speaking the first word pair.
        speakCurrentWordPair()
    }

    /// Stops playback immediately.
    func stopPlayback() {
        wasManuallyStopped = true
        synthesizer.stopSpeaking(at: .immediate)
        playbackState = .stopped
        currentWord = nil
        currentUtteranceType = ""
    }

    /// Pauses playback.
    func pausePlayback() {
        if synthesizer.isSpeaking {
            synthesizer.pauseSpeaking(at: .word)
        }
        playbackState = .paused
    }

    /// Resumes from a paused state.
    func resumePlayback() {
        synthesizer.continueSpeaking()
        playbackState = .playing
        wasManuallyStopped = false
    }

    // MARK: - Private

    /// Builds the playback queue from the currently selected blocks.
    private func buildPlaybackQueue() -> [AudioWord] {
        var queue: [AudioWord] = []

        let selectedBlocks = allBlocks.filter { selectedBlockIDs.contains($0.id) }

        for block in selectedBlocks {
            for word in block.vocabularyWords where !word.translatedWord.isEmpty {
                queue.append(
                    AudioWord(
                        nativeWord: word.nativeWord,
                        translatedWord: word.translatedWord,
                        blockIndex: word.wordBlockIndex,
                        blockName: block.blockName
                    )
                )
            }
        }

        // Shuffle the queue for variety.
        return queue.shuffled()
    }

    /// Speaks the current word pair: native once, then translated N times.
    private func speakCurrentWordPair() {
        guard !wasManuallyStopped, queueIndex < playbackQueue.count else {
            if loopEnabled && !wasManuallyStopped && !playbackQueue.isEmpty {
                queueIndex = 0
                progressIndex = 0
                speakCurrentWordPair()
            } else {
                playbackState = .stopped
                currentWord = nil
                currentUtteranceType = ""
            }
            return
        }

        let word = playbackQueue[queueIndex]
        currentWord = word
        progressIndex = queueIndex + 1

        // Build utterance sequence: native once, then translated N times.
        pendingUtterances = []

        // Native language word (English).
        pendingUtterances.append((word.nativeWord, "en-US", "native"))

        // Target language word (Portuguese) repeated N times.
        for i in 0..<repetitions {
            let label = repetitions > 1 ? "translated (\(i + 1)/\(repetitions))" : "translated"
            pendingUtterances.append((word.translatedWord, "pt-BR", label))
        }

        utteranceIndex = 0
        speakNextUtterance()
    }

    /// Speaks the next utterance in the current word's sequence.
    private func speakNextUtterance() {
        guard !wasManuallyStopped, utteranceIndex < pendingUtterances.count else {
            // All utterances for this word are done — advance to next word.
            if !wasManuallyStopped {
                queueIndex += 1
                speakCurrentWordPair()
            } else {
                playbackState = .stopped
                currentWord = nil
                currentUtteranceType = ""
            }
            return
        }

        let utterance = pendingUtterances[utteranceIndex]
        currentUtteranceType = utterance.label

        let speechUtterance = AVSpeechUtterance(string: utterance.text)
        speechUtterance.rate = AVSpeechUtteranceDefaultSpeechRate
        speechUtterance.volume = 1.0

        if let voice = AVSpeechSynthesisVoice(language: utterance.language) {
            speechUtterance.voice = voice
        }

        // Add gap delay after this utterance.
        speechUtterance.postUtteranceDelay = gapSeconds

        synthesizer.speak(speechUtterance)
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension AudioModeViewModel: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.utteranceIndex += 1
            self.speakNextUtterance()
        }
    }

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didCancel utterance: AVSpeechUtterance
    ) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            if self.wasManuallyStopped {
                self.playbackState = .stopped
                self.currentWord = nil
                self.currentUtteranceType = ""
            }
        }
    }
}
