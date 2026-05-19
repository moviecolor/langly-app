import Foundation
import StoreKit
import SwiftUI

/// Manages StoreKit 2 in-app purchases and cross-promotion for Langly modules.
///
/// Product IDs:
/// - `com.langly.app.commonSentences` — Module 2 ($3.99)
/// - `com.langly.app.pronunciation` — Module 3 ($3.99)
/// - `com.langly.app.qa` — Module 4 ($3.99)
/// - `com.langly.app.fullSuite` — Bundle ($9.95)
@MainActor
final class IAPManager: ObservableObject {
    // MARK: - Published State

    /// All available products fetched from the App Store.
    @Published var products: [Product] = []

    /// Set of product identifiers the user has purchased.
    @Published var purchasedProducts: Set<String> = []

    /// Whether a purchase transaction is currently in progress.
    @Published var isPurchasing: Bool = false

    /// The current SKOverlay for cross-promotion, if presented.
    @Published var overlay: SKOverlay?

    // MARK: - Product Identifiers

    nonisolated static let module2ID = "com.langly.app.commonSentences"
    nonisolated static let module3ID = "com.langly.app.pronunciation"
    nonisolated static let module4ID = "com.langly.app.qa"
    nonisolated static let fullSuiteID = "com.langly.app.fullSuite"

    nonisolated static let allProductIDs: Set<String> = [
        module2ID, module3ID, module4ID, fullSuiteID
    ]

    // MARK: - Properties

    /// Background task listening for completed transactions.
    private var transactionListener: Task<Void, Error>?

    // MARK: - Initialization

    init() {
        transactionListener = listenForTransactions()
        Task { await loadProducts() }
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

    /// Purchases a product by its identifier.
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
                purchasedProducts.insert(productID)
                await transaction.finish()
                print("[IAPManager] Purchased: \(productID)")

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

    /// Restores previous purchases by scanning the transaction history.
    func restorePurchases() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchasedProducts.insert(transaction.productID)
            }
        }
    }

    // MARK: - Accessors

    /// Returns whether a specific module is unlocked.
    func isModuleUnlocked(_ productID: String) -> Bool {
        purchasedProducts.contains(productID)
            || purchasedProducts.contains(Self.fullSuiteID)
    }

    /// Returns whether Module 2 (Common Sentences) is unlocked.
    var isCommonSentencesUnlocked: Bool {
        isModuleUnlocked(Self.module2ID)
    }

    /// Returns whether Module 3 (Pronunciation) is unlocked.
    var isPronunciationUnlocked: Bool {
        isModuleUnlocked(Self.module3ID)
    }

    /// Returns whether Module 4 (Q&A) is unlocked.
    var isQAUnlocked: Bool {
        isModuleUnlocked(Self.module4ID)
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
        Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    _ = await MainActor.run {
                        self.purchasedProducts.insert(transaction.productID)
                    }
                    _ = await transaction.finish()
                }
            }
        }
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
