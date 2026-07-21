import SwiftUI
import SwiftData

/// Settings view — home language, target language, audio playback settings.
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [AppSettings]
    @Environment(\.dismiss) private var dismiss

    @State private var homeLanguage: String = "English"
    @State private var targetLanguage: String = "Portuguese"
    @State private var selectedVoice: String = ""
    @State private var playbackGap: Double = 1.75
    @State private var loopEnabled: Bool = true
    @State private var showSaveFeedback = false

    private let availableLanguages = [
        "English", "Spanish", "French", "German", "Italian",
        "Portuguese", "Japanese", "Mandarin", "Korean", "Arabic",
        "Hindi", "Russian", "Dutch", "Swedish", "Turkish"
    ]

    private let availableVoices = [
        "Default", "Male", "Female"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Language settings.
                        languageSection

                        Divider()
                            .background(Color(hex: 0x00D4AA).opacity(0.3))

                        // Audio playback settings.
                        audioSection

                        Divider()
                            .background(Color(hex: 0x00D4AA).opacity(0.3))

                        // About section.
                        aboutSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveSettings()
                        dismiss()
                    }
                    .foregroundColor(Color(hex: 0x00D4AA))
                }
            }
            .task {
                loadSettings()
            }
            .overlay {
                if showSaveFeedback {
                    saveToast
                }
            }
        }
    }

    // MARK: - Language Section

    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Languages")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)

            // Home language.
            VStack(alignment: .leading, spacing: 8) {
                Text("Home Language (your native language)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)

                Picker("Home Language", selection: $homeLanguage) {
                    ForEach(availableLanguages, id: \.self) { lang in
                        Text(lang).tag(lang)
                    }
                }
                .pickerStyle(.menu)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.appSurface)
                )
            }

            // Target language.
            VStack(alignment: .leading, spacing: 8) {
                Text("Language to Learn")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)

                Picker("Target Language", selection: $targetLanguage) {
                    ForEach(availableLanguages, id: \.self) { lang in
                        Text(lang).tag(lang)
                    }
                }
                .pickerStyle(.menu)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.appSurface)
                )
            }
        }
    }

    // MARK: - Audio Section

    private var audioSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Audio Playback")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)

            // Voice selection.
            VStack(alignment: .leading, spacing: 8) {
                Text("Voice")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)

                Picker("Voice", selection: $selectedVoice) {
                    ForEach(availableVoices, id: \.self) { voice in
                        Text(voice).tag(voice)
                    }
                }
                .pickerStyle(.segmented)
            }

            // Playback gap.
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Silence Gap Between Words")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(String(format: "%.1fs", playbackGap))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: 0x00D4AA))
                }

                Slider(value: $playbackGap, in: 0.5...5.0, step: 0.25)
                    .tint(Color(hex: 0x00D4AA))
            }

            // Loop toggle.
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Loop Playback")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)

                    Text("Repeat the word list continuously")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary.opacity(0.7))
                }

                Spacer()

                Toggle("", isOn: $loopEnabled)
                    .labelsHidden()
                    .tint(Color(hex: 0x00D4AA))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.appSurface)
            )
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: 4) {
                Text("Langly")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)

                Text("Your personal language learning assistant. Add the words you want to learn, practice with matching games, and memorize with audio repetition.")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.appSurface)
            )
        }
    }

    // MARK: - Save Toast

    private var saveToast: some View {
        VStack {
            Spacer()

            Text("Settings Saved!")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: 0x00D4AA))
                )
                .padding(.bottom, 40)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.easeInOut(duration: 0.3), value: showSaveFeedback)
    }

    // MARK: - Helpers

    private func loadSettings() {
        guard let existing = settings.first else {
            // Create default settings if none exist.
            let newSettings = AppSettings()
            modelContext.insert(newSettings)
            try? modelContext.save()
            homeLanguage = newSettings.homeLanguage
            targetLanguage = newSettings.targetLanguage
            selectedVoice = newSettings.selectedVoice
            playbackGap = newSettings.playbackGap
            loopEnabled = newSettings.loopEnabled
            return
        }
        homeLanguage = existing.homeLanguage
        targetLanguage = existing.targetLanguage
        selectedVoice = existing.selectedVoice
        playbackGap = existing.playbackGap
        loopEnabled = existing.loopEnabled
    }

    private func saveSettings() {
        guard let existing = settings.first else { return }
        existing.homeLanguage = homeLanguage
        existing.targetLanguage = targetLanguage
        existing.selectedVoice = selectedVoice
        existing.playbackGap = playbackGap
        existing.loopEnabled = loopEnabled

        do {
            try modelContext.save()
            showSaveFeedback = true
            Task {
                try? await Task.sleep(for: .seconds(1.5))
                showSaveFeedback = false
            }
        } catch {
            print("Failed to save settings: \(error)")
        }
    }
}
