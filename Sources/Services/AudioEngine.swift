import Foundation
import AVFoundation

/// Wraps AVSpeechSynthesizer for text-to-speech playback across Langly modules.
/// Supports repetitions, configurable gaps, and continuous looping.
@MainActor
final class AudioEngine: NSObject, ObservableObject {
    // MARK: - Published State

    @Published var isPlaying: Bool = false
    @Published var currentUtteranceText: String = ""

    // MARK: - Properties

    /// The underlying speech synthesizer.
    private let synthesizer = AVSpeechSynthesizer()

    /// Number of repetitions per word/phrase (1–9).
    var repetitions: Int = 1 {
        didSet { repetitions = max(1, min(9, repetitions)) }
    }

    /// Gap in seconds between utterances within a playback sequence.
    var gapSeconds: Double = 1.75

    /// Whether to loop the entire playback queue continuously.
    var loopEnabled: Bool = true

    /// The selected voice identifier (empty string uses system default).
    var selectedVoice: String = ""

    /// The selected voice gender for pitch adjustment.
    var selectedVoiceGender: String = ""

    /// The current playback queue.
    private var playbackQueue: [String] = []

    /// Current index in the playback queue.
    private var currentIndex: Int = 0

    /// Whether playback was stopped by the user (vs. naturally finishing).
    private var wasStopped: Bool = false

    // MARK: - Initialization

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    // MARK: - Public API

    /// Speaks a single string using the configured voice.
    func speak(_ text: String) {
        let utterance = makeUtterance(text)
        synthesizer.speak(utterance)
        isPlaying = true
        currentUtteranceText = text
    }

    /// Stops all speech immediately.
    func stop() {
        wasStopped = true
        synthesizer.stopSpeaking(at: .immediate)
        isPlaying = false
        currentUtteranceText = ""
    }

    /// Sets the number of repetitions per word (clamped 1–9).
    func setRepetitions(_ count: Int) {
        repetitions = max(1, min(9, count))
    }

    /// Sets the gap in seconds between utterances.
    func setGap(_ seconds: Double) {
        gapSeconds = max(0.1, seconds)
    }

    /// Starts playback of a queue of strings.
    /// Each string is spoken `repetitions` times with `gapSeconds` between utterances.
    /// If `loopEnabled` is true, the queue repeats until `stop()` is called.
    func startPlayback(queue: [String]) {
        guard !queue.isEmpty else { return }

        wasStopped = false
        playbackQueue = queue
        currentIndex = 0
        isPlaying = true

        speakNextInQueue()
    }

    // MARK: - Private

    /// Creates a configured speech utterance for the given text.
    private func makeUtterance(_ text: String) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.volume = 1.0

        // Apply selected voice if available.
        if !selectedVoice.isEmpty,
           let voice = AVSpeechSynthesisVoice(identifier: selectedVoice) {
            utterance.voice = voice
            // Lower pitch for male voice, slightly higher for female.
            if selectedVoiceGender == "Male" {
                utterance.pitchMultiplier = 0.5
            } else {
                utterance.pitchMultiplier = 1.15
            }
        } else {
            // Default to Portuguese (Brazil) voice.
            utterance.voice = AVSpeechSynthesisVoice(language: "pt-BR")
        }

        return utterance
    }

    /// Speaks the next item in the queue, handling repetitions and looping.
    private func speakNextInQueue() {
        guard !wasStopped, currentIndex < playbackQueue.count else {
            if loopEnabled && !wasStopped && !playbackQueue.isEmpty {
                currentIndex = 0
                speakNextInQueue()
            } else {
                isPlaying = false
                currentUtteranceText = ""
            }
            return
        }

        let text = playbackQueue[currentIndex]
        currentUtteranceText = text

        // Speak the current item `repetitions` times.
        for i in 0..<repetitions {
            let utterance = makeUtterance(text)
            // Add a post-utterance pause for the gap (except after the last repetition).
            if i < repetitions - 1 {
                utterance.postUtteranceDelay = gapSeconds
            }
            synthesizer.speak(utterance)
        }
    }

    /// Advances to the next item in the queue.
    private func advanceQueue() {
        currentIndex += 1
        if currentIndex >= playbackQueue.count {
            if loopEnabled && !wasStopped {
                currentIndex = 0
            } else {
                isPlaying = false
                currentUtteranceText = ""
                return
            }
        }
        speakNextInQueue()
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension AudioEngine: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        Task { @MainActor [weak self] in
            self?.advanceQueue()
        }
    }

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didCancel utterance: AVSpeechUtterance
    ) {
        Task { @MainActor [weak self] in
            self?.isPlaying = false
            self?.currentUtteranceText = ""
        }
    }
}
