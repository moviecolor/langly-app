import SwiftUI

// MARK: - Module Dismissal Environment Value
// Allows loading screens to signal "go back to main menu" when a module is locked.
// This is needed because dismiss() doesn't work from NavigationStack roots that are
// embedded as subviews (not presented modally).

struct ModuleDismissalAction {
    nonisolated(unsafe) private let handler: () -> Void

    init(handler: @escaping () -> Void) {
        self.handler = handler
    }

    func callAsFunction() {
        handler()
    }
}

struct ModuleDismissalKey: EnvironmentKey {
    static let defaultValue = ModuleDismissalAction(handler: {})
}

extension EnvironmentValues {
    var moduleDismissal: ModuleDismissalAction {
        get { self[ModuleDismissalKey.self] }
        set { self[ModuleDismissalKey.self] = newValue }
    }
}

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

    /// SF Symbol for the module icon.
    var icon: String {
        switch self {
        case .vocabulary: return "book.fill"
        case .commonSentences: return "text.quote"
        case .pronunciation: return "mic.fill"
        case .qa: return "questionmark.circle.fill"
        }
    }

    /// Accent color for the module.
    var accentColor: Color {
        switch self {
        case .vocabulary: return Color(hex: 0xFF6B35)
        case .commonSentences: return Color(hex: 0xFF69B4)
        case .pronunciation: return Color(hex: 0xB57EDC)
        case .qa: return Color(hex: 0xCCFF00)
        }
    }

    /// Image asset name for this module's loading screen.
    var loadingImageName: String {
        switch self {
        case .vocabulary: return "VocabularyLoading"
        case .commonSentences: return "CommonSentencesLoading"
        case .pronunciation: return "PronunciationLoading"
        case .qa: return "QALoading"
        }
    }
}

/// Main menu view with fixed top icon bar and module content below.
struct MainMenuView: View {
    @State private var selectedTab: AppTab = .vocabulary
    @EnvironmentObject var iapManager: IAPManager

    // Loading overlay state — shown while checking IAP / awaiting 1.5s delay.
    @State private var showLoadingOverlay = false
    @State private var loadingTab: AppTab? = nil

    var body: some View {
        ZStack {
            // Background + icon bar + module content.
            VStack(spacing: 0) {
                // Fixed top icon bar — aligned across the top, safe area aware.
                moduleIconBar
                    .padding(.top, UIApplication.shared.connectedScenes
                        .compactMap { $0 as? UIWindowScene }
                        .first?.windows.first?.safeAreaInsets.top ?? 20)

                Divider()
                    .background(Color.appDivider)

                // Module content area — fills remaining space.
                moduleContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(Color.appBackground)

            // Full-screen loading overlay for locked modules.
            if showLoadingOverlay, let tab = loadingTab {
                ZStack {
                    Color.appBackground.ignoresSafeArea()

                    // The module's branded loading image.
                    Image(tab.loadingImageName)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()

                    VStack {
                        Spacer()
                        ProgressView()
                            .tint(tab.accentColor)
                            .padding(.bottom, 40)
                    }
                    .opacity(showLoadingOverlay ? 1 : 0)
                }
                .ignoresSafeArea()
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .background(Color.appBackground)
        .ignoresSafeArea()
    }

    // MARK: - Fixed Top Icon Bar

    private var moduleIconBar: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    showModuleTab(tab)
                } label: {
                    VStack(spacing: 4) {
                        // Simple SF Symbol icon on white circle background.
                        ZStack {
                            Circle()
                                .fill(Color.appIconBg)
                                .frame(width: 36, height: 36)

                            Image(systemName: tab.icon)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(tab.accentColor)
                        }
                        .overlay(
                            Circle()
                                .stroke(tab.accentColor, lineWidth: selectedTab == tab ? 2.5 : 0)
                        )
                        .opacity(selectedTab == tab ? 1.0 : 0.55)

                        // Module name.
                        Text(tab.title)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(selectedTab == tab ? tab.accentColor : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(Color.appBackground.opacity(0.95))
    }

    // MARK: - Module Content

    @ViewBuilder
    private var moduleContent: some View {
        switch selectedTab {
        case .vocabulary:
            NavigationStack {
                VocabularyLoading(isLocked: false)
                    .environmentObject(iapManager)
            }
            .background(Color.appBackground)
        case .commonSentences:
            if iapManager.isCommonSentencesUnlocked {
                NavigationStack {
                    CommonSentencesView()
                }
                .background(Color.appBackground)
            } else {
                // Module locked — show stub.
                ZStack {
                    Color.appBackground.ignoresSafeArea()
                    Text("Common Sentences")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
            }
        case .pronunciation:
            if iapManager.isPronunciationUnlocked {
                NavigationStack {
                    PronunciationView()
                }
                .background(Color.appBackground)
            } else {
                ZStack {
                    Color.appBackground.ignoresSafeArea()
                    Text("Pronunciation")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
            }
        case .qa:
            if iapManager.isQAUnlocked {
                NavigationStack {
                    QAView()
                }
                .background(Color.appBackground)
            } else {
                ZStack {
                    Color.appBackground.ignoresSafeArea()
                    Text("Q&A")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    // MARK: - Module Selection Logic

    /// Handle module icon tap: show loading overlay, check IAP, then show or dismiss.
    private func showModuleTab(_ tab: AppTab) {
        // Vocabulary is always unlocked.
        guard tab != .vocabulary else {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
            return
        }

        // Load the module if unlocked.
        let isUnlocked: Bool
        switch tab {
        case .commonSentences:
            isUnlocked = iapManager.isCommonSentencesUnlocked
        case .pronunciation:
            isUnlocked = iapManager.isPronunciationUnlocked
        case .qa:
            isUnlocked = iapManager.isQAUnlocked
        case .vocabulary:
            isUnlocked = true
        }

        if isUnlocked {
            loadingTab = tab
            showLoadingOverlay = true
            Task {
                try? await Task.sleep(for: .seconds(0.8))
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                        showLoadingOverlay = false
                    }
                }
            }
        } else {
            // Locked: show loading image for 1.5s then fade out (dismiss back to current tab).
            loadingTab = tab
            showLoadingOverlay = true
            Task {
                try? await Task.sleep(for: .seconds(1.5))
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showLoadingOverlay = false
                    }
                }
            }
        }
    }
}

#Preview {
    MainMenuView()
        .environmentObject(IAPManager())
}
