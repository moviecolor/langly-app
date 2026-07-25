import SwiftUI

/// Pronunciation module — "Coming Soon" page with loading graphic.
struct PronunciationView: View {
    @EnvironmentObject var iapManager: IAPManager

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
                Text("Practice speaking with real-time feedback and improve your accent. Unlock this module when it's ready!")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 110)

                Spacer()

                // Coming Soon badge + title — pinned to the very bottom.
                VStack(spacing: 10) {
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

                    Text("Pronunciation")
                        .font(.title.bold())
                        .foregroundColor(.white)
                }
                .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea()
        .navigationTitle("Pronunciation")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        PronunciationView()
            .environmentObject(IAPManager())
    }
}
