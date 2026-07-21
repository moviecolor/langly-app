import SwiftUI

/// Reusable feature card button — icon + title + subtitle + accessory.
/// Used for mode-selection cards in VocabularyView and similar hub views.
struct FeatureCardButton: View {
    let icon: String
    let iconGradientColors: [Color]
    let title: String
    let subtitle: String
    let accentColors: [Color]
    var chevronColors: [Color]? = nil
    var lineLimit: Int = 3
    var accessory: FeatureAccessory = .chevron
    let action: () -> Void

    enum FeatureAccessory {
        case chevron
        case toggle(isOn: Bool, activeColor: Color)
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon — gradient rounded square.
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: iconGradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }

                // Text.
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(lineLimit)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                // Accessory — chevron or toggle indicator.
                accessoryView
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.appSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                LinearGradient(
                                    colors: accentColors,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1.5
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Accessory View

    @ViewBuilder
    private var accessoryView: some View {
        switch accessory {
        case .chevron:
            Image(systemName: "chevron.right.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(
                    LinearGradient(
                        colors: chevronColors ?? accentColors,
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        case .toggle(let isOn, let activeColor):
            Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 24))
                .foregroundStyle(
                    isOn ? activeColor : Color.gray.opacity(0.3)
                )
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        FeatureCardButton(
            icon: "gamecontroller.fill",
            iconGradientColors: [Color(hex: 0xFF6B35), Color(hex: 0xFF8F5E)],
            title: "Word Match Madness",
            subtitle: "Test your vocabulary — match pairs before time runs out",
            accentColors: [Color(hex: 0xFF6B35).opacity(0.4), Color(hex: 0x00D4AA).opacity(0.3)],
            chevronColors: [Color(hex: 0x00D4AA), Color(hex: 0x00B894)],
            lineLimit: 2,
            action: {}
        )

        FeatureCardButton(
            icon: "shuffle",
            iconGradientColors: [Color(hex: 0x9B59B6), Color(hex: 0x8E44AD)],
            title: "Mix All Blocks",
            subtitle: "Combine words from all your blocks into one game",
            accentColors: [Color.gray.opacity(0.2)],
            lineLimit: 2,
            accessory: .toggle(isOn: false, activeColor: Color(hex: 0x9B59B6)),
            action: {}
        )

        FeatureCardButton(
            icon: "speaker.wave.3.fill",
            iconGradientColors: [Color(hex: 0x3498DB), Color(hex: 0x2980B9)],
            title: "Audio Mode",
            subtitle: "Listen on repeat, memorize, and speak out loud. Set the number of repeats and silence gap between words in settings.",
            accentColors: [Color(hex: 0x3498DB).opacity(0.4), Color(hex: 0x00D4AA).opacity(0.3)],
            chevronColors: [Color(hex: 0x3498DB), Color(hex: 0x2980B9)],
            lineLimit: 3,
            action: {}
        )
    }
    .padding()
    .background(Color.appBackground)
}
