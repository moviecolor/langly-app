import SwiftUI

/// Loading screen for the Vocabulary module.
/// Uses the custom loading page image (V_001.png) — full screen, 1.5s display.
struct VocabularyLoading: View {
    @State private var isVisible = false
    @State private var shouldNavigate = false
    @EnvironmentObject var iapManager: IAPManager

    var body: some View {
        ZStack {
            // Dark background.
            Color.appBackground.ignoresSafeArea()

            // Full-screen loading image — scaled to fill, fades in.
            Image("VocabularyLoading")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .opacity(isVisible ? 1 : 0)
                .animation(.easeIn(duration: 0.8), value: isVisible)

            // Subtle loading indicator at bottom.
            VStack {
                Spacer()
                ProgressView()
                    .tint(Color(hex: 0x00D4AA))
                    .padding(.bottom, 40)
            }
            .opacity(isVisible ? 1 : 0)
        }
        .ignoresSafeArea()
        .navigationDestination(isPresented: $shouldNavigate) {
            VocabularyView()
        }
        .task {
            isVisible = true
            try? await Task.sleep(for: .seconds(1.5))
            shouldNavigate = true
        }
    }
}

#Preview {
    NavigationStack {
        VocabularyLoading()
            .environmentObject(IAPManager())
    }
}
