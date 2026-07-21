import SwiftUI

struct QALoading: View {
    @State private var isVisible = false
    @State private var shouldNavigate = false
    @EnvironmentObject var iapManager: IAPManager

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            Image("QALoading")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .opacity(isVisible ? 1 : 0)
                .animation(.easeIn(duration: 0.8), value: isVisible)
            VStack {
                Spacer()
                ProgressView()
                    .tint(Color(hex: 0xCCFF00))
                    .padding(.bottom, 40)
            }
            .opacity(isVisible ? 1 : 0)
        }
        .ignoresSafeArea()
        .navigationDestination(isPresented: $shouldNavigate) {
            QAView()
        }
        .task {
            isVisible = true
            try? await Task.sleep(for: .seconds(1.5))
            if iapManager.isQAUnlocked {
                shouldNavigate = true
            }
        }
    }
}
