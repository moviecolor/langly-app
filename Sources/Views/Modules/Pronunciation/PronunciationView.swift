import SwiftUI

/// Pronunciation module — "Coming Soon" stub with unlock button.
/// Requires IAP purchase to access.
struct PronunciationView: View {
    @EnvironmentObject var iapManager: IAPManager
    @State private var showPurchaseSheet = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 24) {
            Spacer()

            // Icon
            Image(systemName: "mic.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: 0xB57EDC), Color(hex: 0xFFFDD0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Module title
            Text("Pronunciation")
                .font(.title.bold())

            // Coming soon message
            Text("Practice speaking with real-time feedback and improve your accent.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            // Unlock button
            if !iapManager.isPronunciationUnlocked {
                Button {
                    showPurchaseSheet = true
                } label: {
                    HStack {
                        Image(systemName: "lock.open.fill")
                        Text("Unlock Module")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color(hex: 0xB57EDC), Color(hex: 0xFFFDD0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.appText)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
            } else {
                Text("Module Unlocked")
                    .font(.caption)
                    .foregroundColor(Color(hex: 0xB57EDC))
            }

            Spacer()
            }
        }
        .ignoresSafeArea()
        .navigationTitle("Pronunciation")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPurchaseSheet) {
            purchaseSheet
        }
    }

    @ViewBuilder
    private var purchaseSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Unlock Pronunciation")
                    .font(.title2.bold())

                Text("Perfect your speaking skills for $3.99")
                    .foregroundColor(.secondary)

                Button {
                    Task {
                        await iapManager.purchase(IAPManager.module3ID)
                        showPurchaseSheet = false
                    }
                } label: {
                    Text("Purchase")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: 0xB57EDC))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Button("Cancel") {
                    showPurchaseSheet = false
                }
                .foregroundColor(.secondary)
            }
            .padding()
            .presentationDetents([.medium])
        }
    }
}

#Preview {
    NavigationStack {
        PronunciationView()
            .environmentObject(IAPManager())
    }
}
