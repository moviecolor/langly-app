import SwiftUI
import UIKit

/// Haptic feedback patterns for different app events.
@MainActor
enum HapticPattern {
    case success      // Word saved, game match correct
    case error        // Wrong match, save failed
    case warning      // Streak about to break
    case selection    // Button tap, toggle
    case impact       // Card press, swipe
    case notification // Achievement unlocked, streak milestone

    func trigger() {
        switch self {
        case .success:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

        case .error:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)

        case .warning:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)

        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()

        case .impact:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()

        case .notification:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            // Double-tap for extra emphasis.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                let gen2 = UINotificationFeedbackGenerator()
                gen2.notificationOccurred(.success)
            }
        }
    }
}
