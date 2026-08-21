import SwiftUI
import SwiftData
import AVFoundation

/// Settings view — home language, target language, audio playback settings.
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [AppSettings]
    @Environment(\.dismiss) private var dismiss

    @State private var homeLanguage: String = "English"
    @State private var targetLanguage: String = "Portuguese"
    @State private var selectedVoice: String = ""
    @State private var selectedGender: String = ""
    @AppStorage("selectedVoiceGender") private var savedGender: String = ""
    @State private var playbackGap: Double = 1.75
    @State private var loopEnabled: Bool = true
    @State private var showSaveFeedback = false
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @State private var isVoiceTesting = false
    private let testSynthesizer = AVSpeechSynthesizer()

    private let availableLanguages = [
        "English", "Spanish", "French", "German", "Italian",
        "Portuguese", "Japanese", "Mandarin", "Korean", "Arabic",
        "Hindi", "Russian", "Dutch", "Swedish", "Turkish"
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

                        // Appearance section.
                        appearanceSection

                        Divider()
                            .background(Color(hex: 0x00D4AA).opacity(0.3))

                        // About section.
                        aboutSection

                        Divider()
                            .background(Color(hex: 0x00D4AA).opacity(0.3))

                        // How-to / support section.
                        howToSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Configurações")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Concluir") {
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
            Text("Idiomas")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)

            // Home language.
            VStack(alignment: .leading, spacing: 8) {
                Text("Idioma Nativo (seu idioma)")
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
                Text("Idioma a Aprender")
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
            Text("Reprodução de Áudio")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)

            // Voice selection — real Portuguese voices from the system.
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "waveform")
                        .font(.caption)
                        .foregroundColor(Color(hex: 0x00D4AA))
                    Text("Voz em Português")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }

                if ptVoices.isEmpty {
                    Text("Nenhuma voz em português encontrada")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.appSurface)
                        )
                } else {
                    // Male voices — always show section, use default voice as fallback.
                    Text("Masculino")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            if !maleVoices.isEmpty {
                                ForEach(maleVoices, id: \.identifier) { voice in
                                    voiceChip(voice, gender: "Male")
                                }
                            } else if let fallback = ptVoices.first {
                                voiceChip(fallback, gender: "Male")
                            }
                        }
                    }

                    // Female voices — always show section.
                    Text("Feminino")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            if !femaleVoices.isEmpty {
                                ForEach(femaleVoices, id: \.identifier) { voice in
                                    voiceChip(voice, gender: "Female")
                                }
                            } else if let fallback = ptVoices.first {
                                voiceChip(fallback, gender: "Female")
                            }
                        }
                    }

                    // Other/unspecified voices.
                    if !otherVoices.isEmpty {
                        Text("Outro")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(otherVoices, id: \.identifier) { voice in
                                    voiceChip(voice, gender: "")
                                }
                            }
                        }
                    }
                }

                Text("Baixe vozes de maior qualidade em Configurações → Acessibilidade → Conteúdo Falado → Vozes")
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.7))

                // Voice test button.
                if !selectedVoice.isEmpty {
                    Button {
                        testVoice()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: isVoiceTesting ? "stop.circle.fill" : "play.circle.fill")
                                .font(.title3)
                            Text(isVoiceTesting ? "Reproduzindo..." : "Testar Voz Selecionada")
                                .font(.subheadline.bold())
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(hex: 0x00D4AA))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    .disabled(isVoiceTesting)
                }
            }

            // Playback gap.
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Intervalo de Silêncio Entre Palavras")
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
                    Text("Repetição Contínua")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)

                    Text("Repete a lista de palavras continuamente")
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

    /// Loads all available Portuguese (Brazil) voices from the system.
    private var ptVoices: [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix("pt-B") }
            .sorted { $0.name < $1.name }
    }

    private var maleVoices: [AVSpeechSynthesisVoice] {
        ptVoices.filter { voiceGender($0) == "Male" }
    }

    private var femaleVoices: [AVSpeechSynthesisVoice] {
        ptVoices.filter { voiceGender($0) == "Female" }
    }

    private var otherVoices: [AVSpeechSynthesisVoice] {
        ptVoices.filter { voiceGender($0) == "Unknown" }
    }

    private func voiceGender(_ voice: AVSpeechSynthesisVoice) -> String {
        // Try to detect gender from voice name patterns.
        let name = voice.name.lowercased()
        if name.contains("male") || name.contains("joão") || name.contains("lucas") || name.contains("felipe") {
            return "Male"
        } else if name.contains("female") || name.contains("maria") || name.contains("fernanda") || name.contains("lucia") {
            return "Female"
        }
        // Default: compact voices are often female, enhanced can be either.
        return "Unknown"
    }

    private func voiceDisplayName(_ voice: AVSpeechSynthesisVoice, gender: String) -> String {
        if gender == "Female" { return "Valeria" }
        if gender == "Male" { return "Ryan" }
        return voice.name
    }

    private func voiceChip(_ voice: AVSpeechSynthesisVoice, gender: String = "") -> some View {
        let isSelected = selectedVoice == voice.identifier && selectedGender == gender

        return Button {
            selectedVoice = voice.identifier
            selectedGender = gender
            savedGender = gender
        } label: {
            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: gender == "Male" ? "person.fill" : gender == "Female" ? "person.fill" : "person.fill")
                        .font(.caption2)
                    Text(voiceDisplayName(voice, gender: gender))
                        .font(.subheadline.bold())
                        .lineLimit(1)
                }
                .foregroundColor(isSelected ? .white : .primary)

                HStack(spacing: 4) {
                    if !gender.isEmpty {
                        Text(gender)
                            .font(.caption2)
                    }
                    Text(voiceQualityLabel(voice.quality))
                        .font(.caption2)
                }
                .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
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
    }

    private func voiceQualityLabel(_ quality: AVSpeechSynthesisVoiceQuality) -> String {
        if quality == .enhanced {
            return "avançada"
        }
        return "compacta"
    }

    // MARK: - Appearance Section

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Aparência")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)

            // Dark mode toggle.
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Modo Escuro")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)

                    Text("Alternar entre verde musgo claro e escuro")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary.opacity(0.7))
                }

                Spacer()

                Toggle("", isOn: $isDarkMode)
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
            Text("Sobre")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: 4) {
                Text("Langly")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)

                Text("Seu assistente pessoal de aprendizado de idiomas. Adicione as palavras que quer aprender, pratique com jogos de combinação e memorize com repetição de áudio.")
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

    // MARK: - How-To / Support Section

    private var howToSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Como Usar")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(howToSteps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(hex: 0x005224))
                            .frame(width: 24, height: 24)
                            .background(Circle().fill(Color(hex: 0x00D4AA)))

                        Text(step)
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Divider()

                Link(destination: URL(string: "mailto:support@langly.app")!) {
                    HStack(spacing: 8) {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 14))
                        Text("Suporte: support@langly.app")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(Color(hex: 0x00D4AA))
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.appSurface)
            )
        }
    }

    private var howToSteps: [String] {
        [
            "Toque em um bloco de palavras para começar a jogar",
            "Crie blocos personalizados — até 150 palavras em 10 blocos",
            "Jogue Combinar e Apostar para fixar as palavras",
            "Use o Modo Áudio no trajeto — o áudio repete até fixar",
            "Tudo funciona offline — seus dados ficam no aparelho",
            "Precisa de ajuda? Escreva para support@langly.app"
        ]
    }

    // MARK: - Save Toast

    private var saveToast: some View {
        VStack {
            Spacer()

            Text("Configurações Salvas!")
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
        // Load saved gender selection.
        selectedGender = savedGender
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

    private func testVoice() {
        isVoiceTesting = true
        HapticPattern.impact.trigger()

        let utterance = AVSpeechUtterance(string: "Olá, como vai você? Eu estou aprendendo português.")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        // Lower pitch for male voice, slightly higher for female.
        utterance.pitchMultiplier = selectedGender == "Male" ? 0.5 : 1.15

        if let voice = AVSpeechSynthesisVoice(identifier: selectedVoice) {
            utterance.voice = voice
        }

        utterance.postUtteranceDelay = 0.1
        testSynthesizer.speak(utterance)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            isVoiceTesting = false
        }
    }
}
