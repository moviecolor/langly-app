import SwiftUI

/// Loading screen for the Common Sentences module.
/// Uses the custom loading page image (CS_001.png) — full screen, 1.5s display.
/// If the module is not purchased, shows the loading image then dismisses back to main menu.
struct CommonSentencesLoading: View {
    @State private var isVisible = false
    @State private var shouldNavigate = false
    @EnvironmentObject var iapManager: IAPManager
    @Environment(\.moduleDismissal) private var moduleDismissal

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            Image("CommonSentencesLoading")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .opacity(isVisible ? 1 : 0)
                .animation(.easeIn(duration: 0.8), value: isVisible)

            VStack {
                Spacer()
                ProgressView()
                    .tint(Color(hex: 0xFF69B4))
                    .padding(.bottom, 40)
            }
            .opacity(isVisible ? 1 : 0)
        }
        .ignoresSafeArea()
        .navigationDestination(isPresented: $shouldNavigate) {
            CommonSentencesView()
        }
        .task {
            isVisible = true
            try? await Task.sleep(for: .seconds(1.5))

            if iapManager.isCommonSentencesUnlocked {
                shouldNavigate = true
            } else {
                // Module is locked — dismiss back to main menu.
                moduleDismissal()
            }
        }
    }
}

#Preview {
    NavigationStack {
        CommonSentencesLoading()
            .environmentObject(IAPManager())
    }
}
