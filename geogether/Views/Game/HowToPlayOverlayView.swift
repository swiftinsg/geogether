import SwiftUI

struct HowToPlayOverlayView: View {
    let startGame: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.76)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                ShapeCatView(bodyColor: .orange, size: 72)

                Text("Welcome to GeoPaws")
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text("Walk through each district, learn from its characters and answer their questions.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.86))

                VStack(alignment: .leading, spacing: 14) {
                    InstructionRow(
                        symbol: "gamecontroller.fill",
                        title: "Move",
                        detail: "Use WASD, the arrow keys or the joystick."
                    )
                    InstructionRow(
                        symbol: "sparkles",
                        title: "Open simulations",
                        detail: "Tap the glass bubble to use the same simulations as the main app."
                    )
                    InstructionRow(
                        symbol: "book.closed.fill",
                        title: "Quick Study",
                        detail: "Review questions by topic at any time."
                    )
                }
                .padding()
                .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))

                Button("Start exploring", action: startGame)
                    .font(.headline.bold())
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
            }
            .padding(24)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.25), lineWidth: 1.5))
            .frame(maxWidth: 440)
            .padding()
        }
    }
}

private struct InstructionRow: View {
    let symbol: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }
}
