import SwiftUI

/// Animated audio waveform visualization shown during TTS playback.
struct AudioWaveformView: View {
    let isPlaying: Bool
    let barCount: Int
    let color: Color

    @State private var animating = false

    init(isPlaying: Bool, barCount: Int = 5, color: Color = Color(hex: 0x00D4AA)) {
        self.isPlaying = isPlaying
        self.barCount = barCount
        self.color = color
    }

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(color.opacity(0.8))
                    .frame(width: 3, height: isPlaying ? randomHeight() : 4)
                    .animation(
                        isPlaying
                            ? .easeInOut(duration: Double.random(in: 0.3...0.6))
                                .repeatForever(autoreverses: true)
                            : .easeOut(duration: 0.3),
                        value: animating
                    )
            }
        }
        .frame(height: 24)
        .onAppear {
            if isPlaying {
                animating = true
            }
        }
        .onChange(of: isPlaying) { _, playing in
            animating = playing
        }
    }

    private func randomHeight() -> CGFloat {
        CGFloat.random(in: 6...20)
    }
}

/// Compact waveform for inline use (e.g., in word display).
struct MiniWaveform: View {
    let isActive: Bool

    var body: some View {
        AudioWaveformView(isPlaying: isActive, barCount: 3, color: Color(hex: 0xFF6B35))
            .frame(width: 16, height: 12)
    }
}

#Preview {
    VStack(spacing: 20) {
        AudioWaveformView(isPlaying: true, barCount: 5)
        AudioWaveformView(isPlaying: false, barCount: 5)
        MiniWaveform(isActive: true)
        MiniWaveform(isActive: false)
    }
    .padding()
}
