import SwiftUI

/// Q&A module — "Coming Soon" page with loading graphic.
struct QAView: View {
    @EnvironmentObject var iapManager: IAPManager

    var body: some View {
        ZStack {
            // Full-screen loading graphic.
            Image("QALoading")
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
                Text("Engage in interactive conversations and test your language knowledge. Unlock this module when it's ready!")
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

                    Text("Q&A")
                        .font(.title.bold())
                        .foregroundColor(.white)
                }
                .padding(.bottom, 40)
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
