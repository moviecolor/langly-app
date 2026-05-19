import SwiftUI

/// Q&A module — "Coming Soon" stub with unlock button.
/// Requires IAP purchase to access.
struct QAView: View {
    @EnvironmentObject var iapManager: IAPManager
    @State private var showPurchaseSheet = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 24) {
            Spacer()

            // Icon
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: 0xCCFF00), Color(hex: 0x191970)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Module title
            Text("Q&A")
                .font(.title.bold())

            // Coming soon message
            Text("Engage in interactive conversations and test your language knowledge.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            // Unlock button
            if !iapManager.isQAUnlocked {
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
                            colors: [Color(hex: 0xCCFF00), Color(hex: 0x98FF98)],
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
                    .foregroundColor(Color(hex: 0xCCFF00))
            }

            Spacer()
            }
        }
        .ignoresSafeArea()
        .navigationTitle("Q&A")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPurchaseSheet) {
            purchaseSheet
        }
    }

    @ViewBuilder
    private var purchaseSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Unlock Q&A")
                    .font(.title2.bold())

                Text("Practice conversations for $3.99")
                    .foregroundColor(.secondary)

                Button {
                    Task {
                        await iapManager.purchase(IAPManager.module4ID)
                        showPurchaseSheet = false
                    }
                } label: {
                    Text("Purchase")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: 0xCCFF00))
                        .foregroundColor(.appText)
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
        QAView()
            .environmentObject(IAPManager())
    }
}
