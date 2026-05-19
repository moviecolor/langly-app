import Foundation
import SwiftUI

/// Represents the available language learning modules in Langly.
enum AppModule: String, CaseIterable {
    case vocabulary
    case commonSentences
    case pronunciation
    case qa

    /// The StoreKit product ID associated with this module (if purchasable).
    var productID: String? {
        switch self {
        case .vocabulary:
            return nil // Free module
        case .commonSentences:
            return IAPManager.module2ID
        case .pronunciation:
            return IAPManager.module3ID
        case .qa:
            return IAPManager.module4ID
        }
    }

    /// Display name for the module.
    var displayName: String {
        switch self {
        case .vocabulary: return "Vocabulary"
        case .commonSentences: return "Common Sentences"
        case .pronunciation: return "Pronunciation"
        case .qa: return "Q&A"
        }
    }

    /// SF Symbol icon name for the module.
    var icon: String {
        switch self {
        case .vocabulary: return "book.fill"
        case .commonSentences: return "text.quote"
        case .pronunciation: return "mic.fill"
        case .qa: return "questionmark.circle.fill"
        }
    }
}

/// Destination view for module navigation.
enum ModuleDestination {
    case vocabulary
    case commonSentences
    case pronunciation
    case qa
    case locked(AppModule)
}

/// Routes the user to the appropriate module view, handling IAP gating.
@MainActor
@Observable
final class ModuleRouter {
    var isLoading: Bool = false
    var activeModule: AppModule?

    /// Checks whether a module is available (free or purchased).
    func isModuleAvailable(_ module: AppModule, iapManager: IAPManager) -> Bool {
        guard let productID = module.productID else {
            return true // Free module (Vocabulary)
        }
        return iapManager.isModuleUnlocked(productID)
    }

    /// Navigates to the specified module, returning the appropriate destination.
    func navigateTo(_ module: AppModule, iapManager: IAPManager) async -> ModuleDestination {
        isLoading = true
        activeModule = module

        // Simulate brief loading
        try? await Task.sleep(for: .milliseconds(300))

        defer { isLoading = false }

        guard isModuleAvailable(module, iapManager: iapManager) else {
            return .locked(module)
        }

        switch module {
        case .vocabulary:
            return .vocabulary
        case .commonSentences:
            return .commonSentences
        case .pronunciation:
            return .pronunciation
        case .qa:
            return .qa
        }
    }
}
