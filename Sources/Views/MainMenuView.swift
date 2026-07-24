import SwiftUI

/// App tab enumeration for the main menu.
enum AppTab: Int, CaseIterable {
    case vocabulary = 0
    case commonSentences = 1
    case pronunciation = 2
    case qa = 3

    var title: String {
        switch self {
        case .vocabulary: return "Vocabulary"
        case .commonSentences: return "Common Sentences"
        case .pronunciation: return "Pronunciation"
        case .qa: return "Q&A"
        }
    }

    var icon: String {
        switch self {
        case .vocabulary: return "book.fill"
        case .commonSentences: return "text.quote"
        case .pronunciation: return "mic.fill"
        case .qa: return "questionmark.circle.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .vocabulary: return Color(hex: 0xFF6B35)
        case .commonSentences: return Color(hex: 0xFF69B4)
        case .pronunciation: return Color(hex: 0xB57EDC)
        case .qa: return Color(hex: 0xCCFF00)
        }
    }
}

/// Modules page — shows all modules, Vocabulary is active, others locked.
struct MainMenuView: View {
    @EnvironmentObject var iapManager: IAPManager
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // App title.
                        Text("Langly")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.top, 20)

                        Text("Choose a module to start learning")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .padding(.bottom, 8)

                        // Module cards.
                        ForEach(AppTab.allCases, id: \.self) { tab in
                            moduleCard(tab)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }

    // MARK: - Module Card

    private func moduleCard(_ tab: AppTab) -> some View {
        let isUnlocked: Bool
        switch tab {
        case .vocabulary: isUnlocked = true
        case .commonSentences: isUnlocked = iapManager.isCommonSentencesUnlocked
        case .pronunciation: isUnlocked = iapManager.isPronunciationUnlocked
        case .qa: isUnlocked = iapManager.isQAUnlocked
        }

        return NavigationLink {
            if isUnlocked {
                moduleDestination(for: tab)
                    .navigationBarBackButtonHidden(false)
            } else {
                lockedModuleView(tab)
            }
        } label: {
            HStack(spacing: 16) {
                // Icon circle.
                ZStack {
                    Circle()
                        .fill(tab.accentColor.opacity(0.15))
                        .frame(width: 52, height: 52)

                    Image(systemName: tab.icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(tab.accentColor)
                }

                // Text.
                VStack(alignment: .leading, spacing: 4) {
                    Text(tab.title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.primary)

                    if isUnlocked {
                        Text("Tap to open")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10))
                            Text("Coming soon — purchase to unlock")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.secondary)
                    }
                }

                Spacer()

                if isUnlocked {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(tab.accentColor)
                } else {
                    Image(systemName: "lock.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.gray.opacity(0.4))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.appSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                isUnlocked ? tab.accentColor.opacity(0.3) : Color.gray.opacity(0.15),
                                lineWidth: 1.5
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Module Destination

    @ViewBuilder
    private func moduleDestination(for tab: AppTab) -> some View {
        switch tab {
        case .vocabulary:
            VocabularyView()
        case .commonSentences:
            CommonSentencesView()
        case .pronunciation:
            PronunciationView()
        case .qa:
            QAView()
        }
    }

    // MARK: - Locked Module View

    private func lockedModuleView(_ tab: AppTab) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.5))

            Text(tab.title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)

            Text("This module is coming soon.\nPurchase to unlock when available.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .navigationTitle(tab.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MainMenuView()
        .environmentObject(IAPManager())
}
