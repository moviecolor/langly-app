import SwiftUI

/// Common Sentences module — "Coming Soon" stub with unlock button.
/// Requires IAP purchase to access.
struct CommonSentencesView: View {
    @EnvironmentObject var iapManager: IAPManager
    @State private var showPurchaseSheet = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 24) {
            Spacer()

            // Icon
            Image(systemName: "text.quote")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: 0xFF69B4), Color(hex: 0x98FF98)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Module title
            Text("Common Sentences")
                .font(.title.bold())

            // Coming soon message
            Text("Learn everyday phrases and expressions to boost your conversational skills.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            // Unlock button
            if !iapManager.isCommonSentencesUnlocked {
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
                            colors: [Color(hex: 0xFF69B4), Color(hex: 0x98FF98)],
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
                    .foregroundColor(Color(hex: 0x98FF98))
            }

            Spacer()
            }
        }
        .ignoresSafeArea()
        .navigationTitle("Common Sentences")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPurchaseSheet) {
            purchaseSheet
        }
    }

    @ViewBuilder
    private var purchaseSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Unlock Common Sentences")
                    .font(.title2.bold())

                Text("Master everyday phrases for $3.99")
                    .foregroundColor(.secondary)

                Button {
                    Task {
                        await iapManager.purchase(IAPManager.module2ID)
                        showPurchaseSheet = false
                    }
                } label: {
                    Text("Purchase")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: 0xFF69B4))
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
        CommonSentencesView()
            .environmentObject(IAPManager())
    }
}
