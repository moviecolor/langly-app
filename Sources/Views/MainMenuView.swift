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
}

/// Main menu view with fixed top icon bar and module content below.
struct MainMenuView: View {
    @State private var selectedTab: AppTab = .vocabulary
    @EnvironmentObject var iapManager: IAPManager

    var body: some View {
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
        .ignoresSafeArea()
    }

    // MARK: - Fixed Top Icon Bar

    private var moduleIconBar: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
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
                VocabularyLoading()
            }
            .background(Color.appBackground)
        case .commonSentences:
            NavigationStack {
                CommonSentencesLoading()
            }
            .background(Color.appBackground)
            .environment(\.moduleDismissal, ModuleDismissalAction {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = .vocabulary
                }
            })
        case .pronunciation:
            NavigationStack {
                PronunciationLoading()
            }
            .background(Color.appBackground)
            .environment(\.moduleDismissal, ModuleDismissalAction {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = .vocabulary
                }
            })
        case .qa:
            NavigationStack {
                QALoading()
            }
            .background(Color.appBackground)
            .environment(\.moduleDismissal, ModuleDismissalAction {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = .vocabulary
                }
            })
        }
    }
}

#Preview {
    MainMenuView()
        .environmentObject(IAPManager())
}
