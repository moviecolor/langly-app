import SwiftUI

extension Color {
    /// Creates a Color from a hex integer value.
    /// - Parameter hex: The hex color value (e.g., 0xFF6B35).
    init(hex: UInt) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: 1.0
        )
    }

    // MARK: - Adaptive Theme Colors

    /// App background: moss/sage green in light mode, dark moss green in dark mode.
    static var appBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: 0x2D3D28)
                : UIColor(hex: 0xD0DFC0)
        })
    }

    /// Card/surface background: light gray in light mode, dark overlay in dark mode.
    static var appSurface: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: 0x1A1A2E).withAlphaComponent(0.8)
                : UIColor.systemGray5
        })
    }

    /// Primary text: bright green in dark mode, black in light mode.
    static var appText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.0, green: 1.0, blue: 0.2, alpha: 1.0) // bright green
                : UIColor.black
        })
    }

    /// Secondary text: adapts to mode.
    static var appSecondaryText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.0, green: 0.8, blue: 0.15, alpha: 0.7)
                : UIColor.secondaryLabel
        })
    }

    /// Icon circle background: white in light mode, dark in dark mode.
    static var appIconBg: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: 0x2A2A3E)
                : UIColor.white
        })
    }

    /// Divider color: adapts to mode.
    static var appDivider: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.white.withAlphaComponent(0.1)
                : UIColor.black.withAlphaComponent(0.1)
        })
    }
}

// Helper to create UIColor from hex.
extension UIColor {
    convenience init(hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            alpha: 1.0
        )
    }
}
