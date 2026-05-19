import SwiftUI

/// Full-screen launch screen with Desert Highway neon sign theme.
/// Displays for a minimum of 2.5 seconds with smooth fade-in animation.
struct LaunchScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isVisible = false

    // Scaled metrics for small screen support.
    @ScaledMetric(relativeTo: .largeTitle) var titleSize: CGFloat = 72
    @ScaledMetric(relativeTo: .title2) var welcomeSize: CGFloat = 22
    @ScaledMetric(relativeTo: .body) var subtitleSize: CGFloat = 16

    var body: some View {
        ZStack {
            // Desert Highway background: dark navy
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 12) {
                // "Welcome to" — small, top
                Text("Welcome to")
                    .font(.system(size: welcomeSize, weight: .light, design: .default))
                    .foregroundColor(Color(hex: 0x00D4AA).opacity(0.85))
                    .tracking(2)
                    .padding(.top, 40)

                Spacer()

                // "LANGLY" — very large, center, glow effect
                Text("LANGLY")
                    .font(.system(size: titleSize, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: 0xFF6B35), Color(hex: 0x00D4AA)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color(hex: 0xFF6B35).opacity(0.6), radius: 20, x: 0, y: 0)
                    .shadow(color: Color(hex: 0x00D4AA).opacity(0.4), radius: 30, x: 0, y: 0)

                Spacer()

                // "your language learning assistant" — small, bottom
                Text("your language learning assistant")
                    .font(.system(size: subtitleSize, weight: .regular, design: .default))
                    .foregroundColor(Color(hex: 0x00D4AA).opacity(0.7))
                    .tracking(1)
                    .padding(.bottom, 60)
            }
        }
        .ignoresSafeArea()
        .opacity(isVisible ? 1 : 0)
        .animation(.easeIn(duration: 0.8), value: isVisible)
        .task {
            isVisible = true
            try? await Task.sleep(for: .seconds(2.5))
            dismiss()
        }
    }
}

#Preview {
    LaunchScreen()
}
