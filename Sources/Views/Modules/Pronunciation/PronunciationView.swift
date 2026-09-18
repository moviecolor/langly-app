import SwiftUI
import SwiftData

/// Pronunciation module — "Coming Soon" page with loading graphic.
struct PronunciationView: View {
    @EnvironmentObject var iapManager: IAPManager
    @Query private var settings: [AppSettings]

    /// Localized chrome string for the user's home language — "Portuguese"
    /// renders Brazilian Portuguese, everything else renders English.
    private func L(_ key: String) -> String {
        Localization.string(key, homeLanguage: settings.first?.homeLanguage)
    }

    var body: some View {
        ZStack {
            // Full-screen loading graphic.
            Image("PronunciationLoading")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .ignoresSafeArea()

            // Subtle overlay for readability.
            LinearGradient(
                colors: [.clear, .black.opacity(0.5)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Content: description at top, badge at bottom.
            VStack {
                // Description — pinned to the top.
                Text(L("module.pronunciation.body"))
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 110)

                Spacer()

                // Coming Soon badge + title — pinned to the very bottom.
                VStack(spacing: 10) {
                    Text(L("module.comingSoon"))
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundColor(.white)
                        .tracking(3)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.6))
                        )

                    Text(L("module.pronunciation"))
                        .font(.title.bold())
                        .foregroundColor(.white)
                }
                .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea()
        .navigationTitle(L("module.pronunciation"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        PronunciationView()
            .environmentObject(IAPManager())
    }
    .modelContainer(for: AppSettings.self)
}
