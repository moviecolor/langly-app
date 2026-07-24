import SwiftUI

/// Q&A module — "Coming Soon" page with loading graphic.
struct QAView: View {
    @EnvironmentObject var iapManager: IAPManager

    var body: some View {
        ZStack {
            // Full-screen loading graphic from bundle.
            BundleImage(name: "Q_Loading")

            // Subtle overlay for readability.
            LinearGradient(
                colors: [.clear, .black.opacity(0.5)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Content overlay.
            VStack(spacing: 20) {
                Spacer()

                // Coming Soon badge.
                Text("COMING SOON")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(.white)
                    .tracking(3)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.6))
                    )

                // Module title.
                Text("Q&A")
                    .font(.title.bold())
                    .foregroundColor(.white)

                // Description.
                Text("Engage in interactive conversations and test your language knowledge. Unlock this module when it's ready!")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()
            }
        }
        .ignoresSafeArea()
        .navigationTitle("Q&A")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        QAView()
            .environmentObject(IAPManager())
    }
}
