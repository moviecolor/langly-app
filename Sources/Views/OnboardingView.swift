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

    /// Localized chrome string for the user's home language — "Portuguese"
    /// renders Brazilian Portuguese, everything else renders English.
    private func L(_ key: String) -> String {
        Localization.string(key, homeLanguage: settings.first?.homeLanguage)
    }

    /// Sample words for the "hear it" preview — one entry per supported
    /// direction, keyed by the language the user is learning.
    private let sampleWords: [String: (native: String, translated: String, voiceCode: String)] = [
        "Portuguese": ("Hello", "Olá", "pt-BR"),
        "English": ("Olá", "Hello", "en-US")
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

            Text(L("onboarding.modules.title"))
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)

            VStack(spacing: 16) {
                moduleRow(icon: "character.book.closed.fill", title: L("module.vocabulary"), subtitle: L("onboarding.modules.vocabulary"), color: 0xFF6B35)
                moduleRow(icon: "bubble.left.and.bubble.right.fill", title: L("module.commonSentences"), subtitle: L("onboarding.modules.commonSentences"), color: 0xFF69B4)
                moduleRow(icon: "mic.fill", title: L("module.pronunciation"), subtitle: L("onboarding.modules.pronunciation"), color: 0xB57EDC)
                moduleRow(icon: "questionmark.circle.fill", title: L("module.qa"), subtitle: L("onboarding.modules.qa"), color: 0xCCFF00)
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
                Text(L("onboarding.addWords.title"))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)

                Text(L("onboarding.addWords.body"))
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Who are you? — two large direction cards that set the translation
            // direction (home language → learning language).
            VStack(alignment: .leading, spacing: 14) {
                Text("Who Are You?")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)

                languageCard(
                    flag: "🇺🇸",
                    title: "I speak English",
                    subtitle: "Learn Portuguese",
                    language: "Portuguese"
                )

                languageCard(
                    flag: "🇧🇷",
                    title: "Eu falo Português",
                    subtitle: "Aprenda Inglês",
                    language: "English"
                )

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
                                Text(L("onboarding.tapToHear"))
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

    /// A large selectable direction card. The selected card shows an accent border.
    private func languageCard(
        flag: String,
        title: String,
        subtitle: String,
        language: String
    ) -> some View {
        let isSelected = selectedLanguage == language
        return Button {
            HapticPattern.selection.trigger()
            selectedLanguage = language
        } label: {
            HStack(spacing: 16) {
                Text(flag)
                    .font(.system(size: 36))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? Color(hex: 0x00D4AA) : Color.gray.opacity(0.35))
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.appSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? Color(hex: 0x00D4AA) : Color.gray.opacity(0.15),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
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

                Text(L("onboarding.getStarted.title"))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)

                // Display-only language name (the machine value stays as-is).
                let displayLanguageName = selectedLanguage == "English"
                    ? L("language.name.english")
                    : L("language.name.portuguese")
                Text(String(format: L("onboarding.getStarted.body"), displayLanguageName.lowercased()))
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
                    // Save the user's identity (home language) and learning
                    // direction, then dismiss.
                    if let settings = settings.first {
                        settings.targetLanguage = selectedLanguage
                        settings.homeLanguage = selectedLanguage == "English" ? "Portuguese" : "English"
                        settings.hasCompletedOnboarding = true
                        try? modelContext.save()
                    }
                    showMainApp = true
                }
            } label: {
                Text(currentPage < 3 ? L("onboarding.continue") : L("onboarding.startLearning"))
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
                    Text(L("onboarding.skip"))
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
