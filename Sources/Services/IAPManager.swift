import Foundation
import StoreKit
import SwiftUI

/// Manages StoreKit 2 in-app purchases for Langly.
///
/// Product IDs:
/// - `com.langly.app.premium.monthly` — Langly Premium monthly auto-renewable
///   subscription (USA $8.99 / BRA R$ 26,90). Unlocks Modules 2–4.
///
/// Entitlements are derived from `Transaction.currentEntitlements`, so the
/// subscription restores automatically on any device signed in with the same
/// Apple ID.
@MainActor
final class IAPManager: ObservableObject {
    // MARK: - Published State

    /// All available products fetched from the App Store.
    @Published var products: [Product] = []

    /// Whether the auto-renewable Langly Premium subscription is currently active.
    @Published var isPremiumActive: Bool = false

    /// Whether a purchase transaction is currently in progress.
    @Published var isPurchasing: Bool = false

    /// The current SKOverlay for cross-promotion, if presented.
    @Published var overlay: SKOverlay?

    // MARK: - Product Identifiers

    /// Langly Premium — monthly auto-renewable subscription.
    nonisolated static let premiumMonthlyID = "com.langly.app.premium.monthly"

    nonisolated static let allProductIDs: Set<String> = [
        premiumMonthlyID
    ]

    // MARK: - Properties

    /// Background task listening for completed transactions.
    private var transactionListener: Task<Void, Error>?

    // MARK: - Initialization

    init() {
        transactionListener = listenForTransactions()
        Task {
            await loadProducts()
            await refreshEntitlements()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Product Loading

    /// Fetches product information from the App Store.
    func loadProducts() async {
        do {
            products = try await Product.products(for: Self.allProductIDs)
        } catch {
            print("[IAPManager] Failed to load products: \(error.localizedDescription)")
        }
    }

    // MARK: - Purchasing

    /// Purchases a product by its identifier (auto-renewable subscription or one-time).
    func purchase(_ productID: String) async {
        guard let product = products.first(where: { $0.id == productID }) else {
            print("[IAPManager] Product not found: \(productID)")
            return
        }

        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                print("[IAPManager] Purchased: \(productID)")
                // Re-derive entitlements so the UI unlocks immediately.
                await refreshEntitlements()

            case .userCancelled:
                break

            case .pending:
                break

            @unknown default:
                break
            }
        } catch {
            print("[IAPManager] Purchase failed: \(error.localizedDescription)")
        }
    }

    /// Restores previous purchases by scanning the current entitlements.
    /// Auto-renewable subscriptions restore automatically on the same Apple ID.
    func restorePurchases() async {
        await refreshEntitlements()
    }

    // MARK: - Entitlements

    /// Recomputes `isPremiumActive` from `Transaction.currentEntitlements`.
    func refreshEntitlements() async {
        var active = false
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transaction.productID == Self.premiumMonthlyID {
                active = true
            }
        }
        isPremiumActive = active
        print("[IAPManager] isPremiumActive = \(active)")
    }

    // MARK: - Accessors

    /// Returns whether a gated module is unlocked.
    /// All premium modules share the single Langly Premium entitlement.
    func isModuleUnlocked(_ productID: String) -> Bool {
        isPremiumActive
    }

    /// Returns whether Module 2 (Common Sentences) is unlocked.
    var isCommonSentencesUnlocked: Bool {
        isPremiumActive
    }

    /// Returns whether Module 3 (Pronunciation) is unlocked.
    var isPronunciationUnlocked: Bool {
        isPremiumActive
    }

    /// Returns whether Module 4 (Q&A) is unlocked.
    var isQAUnlocked: Bool {
        isPremiumActive
    }

    // MARK: - Cross-Promo Overlay

    /// Presents the StoreKit cross-promotion overlay from the given window scene.
    func presentCrossPromo(from windowScene: UIWindowScene) {
        // SKOverlay requires AppClipConfiguration or AppOverlayConfiguration.
        // For now, this is a placeholder — implement when cross-promo is needed.
        print("[IAPManager] Cross-promo overlay placeholder")
    }

    // MARK: - Transaction Listening

    /// Listens for completed transactions in the background.
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await self?.onTransactionVerified()
                    _ = await transaction.finish()
                }
            }
        }
    }

    /// Handles a verified transaction on the MainActor.
    @MainActor
    private func onTransactionVerified() {
        Task { await refreshEntitlements() }
    }

    // MARK: - Helpers

    /// Verifies a transaction's cryptographic signature.
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }
}
