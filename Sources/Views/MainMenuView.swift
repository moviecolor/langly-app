import SwiftUI
import StoreKit

/// App tab enumeration for the main menu.
enum AppTab: Int, CaseIterable {
    case vocabulary = 0
    case commonSentences = 1
    case pronunciation = 2
    case qa = 3

    var title: String {
        switch self {
        case .vocabulary: return "Vocabulário"
        case .commonSentences: return "Frases Comuns"
        case .pronunciation: return "Pronúncia"
        case .qa: return "Perguntas e Respostas"
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
    @State private var showAchievements = false
    @State private var showStats = false
    @State private var showPaywall = false

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

                        Text("Escolha um módulo para começar a aprender")
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
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 16) {
                        Button {
                            showAchievements = true
                        } label: {
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.secondary)
                        }
                        Button {
                            showStats = true
                        } label: {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
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
            .sheet(isPresented: $showAchievements) {
                NavigationStack {
                    AchievementsView()
                }
            }
            .sheet(isPresented: $showStats) {
                NavigationStack {
                    StatsView()
                }
            }
            .fullScreenCover(isPresented: $showPaywall) {
                PaywallView()
                    .environmentObject(iapManager)
            }
        }
    }

    // MARK: - Module Card

    @State private var pressedCard: AppTab?

    private func moduleCard(_ tab: AppTab) -> some View {
        let isUnlocked: Bool
        switch tab {
        case .vocabulary: isUnlocked = true
        case .commonSentences: isUnlocked = iapManager.isCommonSentencesUnlocked
        case .pronunciation: isUnlocked = iapManager.isPronunciationUnlocked
        case .qa: isUnlocked = iapManager.isQAUnlocked
        }

        return NavigationLink {
            moduleDestination(for: tab)
                .navigationBarBackButtonHidden(false)
        } label: {
            HStack(spacing: 16) {
                // Icon — gradient circle.
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [tab.accentColor.opacity(0.2), tab.accentColor.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
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
                        Text("Toque para abrir")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10))
                            Text("Disponível com Langly Premium")
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
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.appSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isUnlocked
                                    ? LinearGradient(
                                        colors: [tab.accentColor.opacity(0.4), tab.accentColor.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                      )
                                    : LinearGradient(
                                        colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                      ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: isUnlocked ? tab.accentColor.opacity(0.1) : .clear, radius: 8, x: 0, y: 4)
            )
            .scaleEffect(pressedCard == tab ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: pressedCard)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressedCard = tab }
                .onEnded { _ in pressedCard = nil }
        )
    }

    // MARK: - Module Destination

    @ViewBuilder
    private func moduleDestination(for tab: AppTab) -> some View {
        switch tab {
        case .vocabulary:
            VocabularyView()
        case .commonSentences:
            if iapManager.isCommonSentencesUnlocked {
                CommonSentencesView()
            } else {
                lockedModuleView(tab)
            }
        case .pronunciation:
            if iapManager.isPronunciationUnlocked {
                PronunciationView()
            } else {
                lockedModuleView(tab)
            }
        case .qa:
            if iapManager.isQAUnlocked {
                QAView()
            } else {
                lockedModuleView(tab)
            }
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

            Text("Este módulo faz parte do Langly Premium.\nAssine para desbloquear todos os módulos.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showPaywall = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text("Desbloquear com Langly Premium")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Color(hex: 0x00A34A), Color(hex: 0x008C3F)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 24)
        .navigationTitle(tab.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MainMenuView()
        .environmentObject(IAPManager())
}

// MARK: - Paywall

/// Full-screen paywall for the Langly Premium monthly subscription.
struct PaywallView: View {
    @EnvironmentObject var iapManager: IAPManager
    @Environment(\.dismiss) private var dismiss

    /// The Langly Premium subscription product, when loaded.
    private var product: Product? {
        iapManager.products.first { $0.id == IAPManager.premiumMonthlyID }
    }

    var body: some View {
        ZStack {
            // Brand gradient background.
            LinearGradient(
                colors: [
                    Color(hex: 0x00A34A),
                    Color(hex: 0x008C3F),
                    Color(hex: 0x005224)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Close button.
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 26))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }

                    Spacer().frame(height: 8)

                    // Logo: gold diamond with the blue ball in front.
                    ZStack {
                        Rectangle()
                            .fill(Color(hex: 0xFFDF00).opacity(0.15))
                            .frame(width: 68, height: 68)
                            .rotationEffect(.degrees(45))
                        Rectangle()
                            .stroke(Color(hex: 0xFFDF00), lineWidth: 2.5)
                            .frame(width: 68, height: 68)
                            .rotationEffect(.degrees(45))
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: 0x66B2FF), Color(hex: 0x0055CC)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 30, height: 30)
                            .overlay(Circle().stroke(Color.white.opacity(0.7), lineWidth: 1.5))
                            .offset(x: 16, y: 16)
                    }
                    .frame(height: 90)

                    Text("Langly Premium")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)

                    Text("Seu trajeto é a sua sala de aula.")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.85))

                    // Benefits card.
                    VStack(alignment: .leading, spacing: 14) {
                        benefitRow(icon: "infinity", text: "Gameplay ilimitado — sem vidas, sem limites")
                        benefitRow(icon: "waveform", text: "Listas personalizadas com áudio em loop")
                        benefitRow(icon: "wifi.slash", text: "Funciona 100% offline")
                        benefitRow(icon: "nosign", text: "Sem anúncios")
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.12))
                    )

                    Spacer().frame(height: 8)

                    // Subscribe button.
                    if let product {
                        Button {
                            Task {
                                await iapManager.purchase(IAPManager.premiumMonthlyID)
                                if iapManager.isPremiumActive {
                                    dismiss()
                                }
                            }
                        } label: {
                            HStack {
                                if iapManager.isPurchasing {
                                    ProgressView()
                                        .tint(Color(hex: 0x005224))
                                } else {
                                    Text("Assinar por \(product.displayPrice)/mês")
                                        .font(.system(size: 18, weight: .bold))
                                }
                            }
                            .foregroundColor(Color(hex: 0x005224))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: 0xFFE25C), Color(hex: 0xFFD200)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(18)
                        }
                        .disabled(iapManager.isPurchasing)
                    } else {
                        ProgressView()
                            .tint(.white)
                            .padding(.vertical, 16)
                    }

                    // Restore.
                    Button {
                        Task { await iapManager.restorePurchases() }
                    } label: {
                        Text("Restaurar Compra")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.top, 4)

                    // Terms.
                    VStack(spacing: 6) {
                        Text("A assinatura é renovada automaticamente até ser cancelada. O pagamento é cobrado na sua conta Apple ID na confirmação da compra.")
                            .font(.system(size: 11))
                            .multilineTextAlignment(.center)
                        HStack(spacing: 12) {
                            Link(
                                "Termos de Uso",
                                destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
                            )
                            Link(
                                "Privacidade",
                                destination: URL(string: "https://moviecolor.github.io/langly-app/")!
                            )
                        }
                        .font(.system(size: 11))
                    }
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 8)
                }
                .padding(24)
            }
        }
        .onAppear {
            if iapManager.products.isEmpty {
                Task { await iapManager.loadProducts() }
            }
        }
    }

    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color(hex: 0xFFE25C))
                .frame(width: 28)
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.white)
        }
    }
}
