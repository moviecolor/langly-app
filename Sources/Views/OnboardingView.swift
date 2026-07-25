import SwiftUI
import SwiftData
import AVFoundation

/// Onboarding flow — first-launch walkthrough for new users.
/// Shows 4 screens: Welcome, Modules, Add Words, Get Started.
struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [AppSettings]
    @State private var currentPage = 0
    @State private var selectedLanguage = "Portuguese"
    @State private var showMainApp = false
    @State private var isPreviewPlaying = false

    private let synthesizer = AVSpeechSynthesizer()

    private let languages = ["Portuguese", "Spanish", "French", "German", "Italian", "Japanese", "Korean", "Chinese"]

    /// Sample words for language preview.
    private let sampleWords: [String: (native: String, translated: String, voiceCode: String)] = [
        "Portuguese": ("Hello", "Olá", "pt-BR"),
        "Spanish": ("Hello", "Hola", "es-ES"),
        "French": ("Hello", "Bonjour", "fr-FR"),
        "German": ("Hello", "Hallo", "de-DE"),
        "Italian": ("Hello", "Ciao", "it-IT"),
        "Japanese": ("Hello", "こんにちは", "ja-JP"),
        "Korean": ("Hello", "안녕하세요", "ko-KR"),
        "Chinese": ("Hello", "你好", "zh-CN")
    ]

    var body: some View {
        ZStack {
            // Background gradient.
            LinearGradient(
                colors: [
                    Color(hex: 0x0A0A0F),
                    Color(hex: 0x0A0A0F).opacity(0.95),
                    Color(hex: 0xFF6B35).opacity(0.08)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Page content.
                TabView(selection: $currentPage) {
                    welcomePage.tag(0)
                    modulesPage.tag(1)
                    addWordsPage.tag(2)
                    getStartedPage.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                // Bottom controls.
                bottomControls
            }
        }
        .fullScreenCover(isPresented: $showMainApp) {
            ContentView()
        }
    }

    // MARK: - Page 1: Welcome

    private var welcomePage: some View {
        VStack(spacing: 32) {
            Spacer()

            // Logo animation.
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: 0xFF6B35), Color(hex: 0x00D4AA)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: Color(hex: 0xFF6B35).opacity(0.4), radius: 30)

                Image(systemName: "text.book.closed.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }

            VStack(spacing: 12) {
                Text("Welcome to Langly")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)

                Text("Your personal language learning assistant")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Page 2: Modules

    private var modulesPage: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("4 Learning Modules")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)

            VStack(spacing: 16) {
                moduleRow(icon: "character.book.closed.fill", title: "Vocabulary", subtitle: "Build your word bank", color: 0xFF6B35)
                moduleRow(icon: "bubble.left.and.bubble.right.fill", title: "Common Sentences", subtitle: "Learn everyday phrases", color: 0xFF69B4)
                moduleRow(icon: "mic.fill", title: "Pronunciation", subtitle: "Master your accent", color: 0xB57EDC)
                moduleRow(icon: "questionmark.circle.fill", title: "Q&A", subtitle: "Practice conversations", color: 0xCCFF00)
            }

            Spacer()
        }
        .padding(.horizontal, 32)
    }

    private func moduleRow(icon: String, title: String, subtitle: String, color: UInt) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: color).opacity(0.15))
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(Color(hex: color))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.appSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(hex: color).opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - Page 3: Add Words

    private var addWordsPage: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "plus.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: 0x00D4AA), Color(hex: 0x00B894)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: 12) {
                Text("Start Adding Words")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)

                Text("Tap the + button to add your first words. We'll auto-translate them for you!")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Language selector with preview.
            VStack(alignment: .leading, spacing: 12) {
                Text("Learning Language")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(languages, id: \.self) { lang in
                            languageChip(lang)
                        }
                    }
                }

                // Preview button.
                if let sample = sampleWords[selectedLanguage] {
                    Button {
                        previewLanguage(sample)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: isPreviewPlaying ? "stop.circle.fill" : "play.circle.fill")
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(sample.native) → \(sample.translated)")
                                    .font(.subheadline.bold())
                                Text("Tap to hear it")
                                    .font(.caption)
                                    .opacity(0.7)
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: 0x00D4AA))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 32)
    }

    private func languageChip(_ lang: String) -> some View {
        Button {
            HapticPattern.selection.trigger()
            selectedLanguage = lang
        } label: {
            Text(lang)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(selectedLanguage == lang ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(selectedLanguage == lang ? Color(hex: 0x00D4AA) : Color.appSurface)
                )
        }
        .buttonStyle(.plain)
    }

    private func previewLanguage(_ sample: (native: String, translated: String, voiceCode: String)) {
        isPreviewPlaying = true
        HapticPattern.impact.trigger()

        let utterance = AVSpeechUtterance(string: sample.translated)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.voice = AVSpeechSynthesisVoice(language: sample.voiceCode)

        utterance.postUtteranceDelay = 0.1
        synthesizer.speak(utterance)

        // Reset after playback.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isPreviewPlaying = false
        }
    }

    // MARK: - Page 4: Get Started

    private var getStartedPage: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: 0xFF6B35), Color(hex: 0x00D4AA)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("You're All Set!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)

                Text("Start learning \(selectedLanguage.lowercased()) today. Your progress is saved locally and stays private.")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        VStack(spacing: 16) {
            // Page dots.
            HStack(spacing: 8) {
                ForEach(0..<4) { index in
                    Circle()
                        .fill(index == currentPage ? Color(hex: 0x00D4AA) : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut, value: currentPage)
                }
            }

            // Action button.
            Button {
                HapticPattern.impact.trigger()
                if currentPage < 3 {
                    withAnimation {
                        currentPage += 1
                    }
                } else {
                    // Save language preference and dismiss.
                    if let settings = settings.first {
                        settings.targetLanguage = selectedLanguage
                        settings.hasCompletedOnboarding = true
                        try? modelContext.save()
                    }
                    showMainApp = true
                }
            } label: {
                Text(currentPage < 3 ? "Continue" : "Start Learning")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: 0xFF6B35), Color(hex: 0x00D4AA)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)

            // Skip button.
            if currentPage < 3 {
                Button {
                    showMainApp = true
                } label: {
                    Text("Skip")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 40)
    }
}

#Preview {
    OnboardingView()
        .modelContainer(for: AppSettings.self)
}
