import SwiftUI

/// Common Sentences module — "Coming Soon" page with loading graphic.
struct CommonSentencesView: View {
    @EnvironmentObject var iapManager: IAPManager

    var body: some View {
        ZStack {
            // Full-screen loading graphic from bundle.
            BundleImage(name: "CS_Loading")

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
                Text("Common Sentences")
                    .font(.title.bold())
                    .foregroundColor(.white)

                // Description.
                Text("Learn everyday phrases and expressions to boost your conversational skills. Unlock this module when it's ready!")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()
            }
        }
        .ignoresSafeArea()
        .navigationTitle("Common Sentences")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        CommonSentencesView()
            .environmentObject(IAPManager())
    }
}
