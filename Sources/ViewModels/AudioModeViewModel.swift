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

/// ViewModel for Audio Mode — plays each word pair N times, loops until stopped.
@MainActor
final class AudioModeViewModel: NSObject, ObservableObject {
    // MARK: - Published State

    @Published var playbackState: AudioPlaybackState = .stopped
    @Published var currentWord: AudioWord?
    @Published var currentUtteranceType: String = ""
    @Published var progressIndex: Int = 0
    @Published var totalWordsInQueue: Int = 0
    @Published var selectedBlockIDs: Set<UUID> = []
    @Published var repetitions: Int = 4
    @Published var gapSeconds: Double = 1.5

    // MARK: - Properties

    private let synthesizer = AVSpeechSynthesizer()
    private var allBlocks: [WordBlock] = []
    private var playbackQueue: [AudioWord] = []
    private var queueIndex: Int = 0
    private var wasManuallyStopped: Bool = false

    /// How many times the current word pair has been spoken in this round.
    private var currentWordRepetition: Int = 0

    /// Pending utterance sequence for current word: [(text, language, label)]
    private var pendingUtterances: [(text: String, language: String, label: String)] = []
    private var utteranceIndex: Int = 0

    /// User-selected voice identifier for Portuguese (from AppSettings).
    /// Empty string means use system default for the language.
    var selectedVoiceIdentifier: String = ""

    // MARK: - Initialization

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    // MARK: - Public API

    func loadBlocks(_ blocks: [WordBlock]) {
        allBlocks = blocks
    }

    func toggleBlockSelection(_ blockID: UUID) {
        if selectedBlockIDs.contains(blockID) {
            selectedBlockIDs.remove(blockID)
        } else {
            selectedBlockIDs.insert(blockID)
        }
    }

    func selectAllActiveBlocks() {
        selectedBlockIDs = Set(allBlocks.filter { $0.isActive }.map { $0.id })
    }

    func clearSelection() {
        selectedBlockIDs.removeAll()
    }

    func startPlayback() {
        playbackQueue = buildPlaybackQueue()
        guard !playbackQueue.isEmpty else { return }

        wasManuallyStopped = false
        queueIndex = 0
        currentWordRepetition = 0
        totalWordsInQueue = playbackQueue.count
        progressIndex = 1
        playbackState = .playing

        speakCurrentWordPair()
    }

    func stopPlayback() {
        wasManuallyStopped = true
        synthesizer.stopSpeaking(at: .immediate)
        playbackState = .stopped
        currentWord = nil
        currentUtteranceType = ""
    }

    func pausePlayback() {
        if synthesizer.isSpeaking {
            synthesizer.pauseSpeaking(at: .word)
        }
        playbackState = .paused
    }

    func resumePlayback() {
        synthesizer.continueSpeaking()
        playbackState = .playing
        wasManuallyStopped = false
    }

    // MARK: - Private

    private func buildPlaybackQueue() -> [AudioWord] {
        var queue: [AudioWord] = []
        let selectedBlocks = allBlocks.filter { selectedBlockIDs.contains($0.id) }
        for block in selectedBlocks {
            for word in block.vocabularyWords where !word.translatedWord.isEmpty {
                queue.append(AudioWord(
                    nativeWord: word.nativeWord,
                    translatedWord: word.translatedWord,
                    blockIndex: word.wordBlockIndex,
                    blockName: block.blockName
                ))
            }
        }
        return queue.shuffled()
    }

    /// Plays the current word pair: native once, then translated once.
    /// After all utterances, repeats if under the repetition count.
    private func speakCurrentWordPair() {
        guard !wasManuallyStopped, queueIndex < playbackQueue.count else {
            // Queue exhausted — loop back to start.
            if !wasManuallyStopped && !playbackQueue.isEmpty {
                queueIndex = 0
                currentWordRepetition = 0
                progressIndex = 1
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

        // Build utterance sequence: native once, then translated once.
        pendingUtterances = [
            (word.nativeWord, "en-US", "English"),
            (word.translatedWord, "pt-BR", "Portuguese")
        ]

        utteranceIndex = 0
        speakNextUtterance()
    }

    private func speakNextUtterance() {
        guard !wasManuallyStopped, utteranceIndex < pendingUtterances.count else {
            // Done with this utterance sequence for the current word.
            currentWordRepetition += 1

            if !wasManuallyStopped {
                if currentWordRepetition < repetitions {
                    // Repeat the same word pair.
                    currentWordRepetition += 1
                    speakCurrentWordPair()
                } else {
                    // Move to next word.
                    currentWordRepetition = 0
                    queueIndex += 1
                    speakCurrentWordPair()
                }
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

        // Use the user-selected voice for Portuguese, system default for English.
        if utterance.language.hasPrefix("pt"),
           !selectedVoiceIdentifier.isEmpty,
           let voice = AVSpeechSynthesisVoice(identifier: selectedVoiceIdentifier) {
            speechUtterance.voice = voice
        } else if let voice = AVSpeechSynthesisVoice(language: utterance.language) {
            speechUtterance.voice = voice
        }

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
