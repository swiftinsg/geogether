import SwiftUI

/// Ring that shows a score as a percentage.
struct ScoreRing: View {
    let fraction: Double
    let tint: Color
    var lineWidth: CGFloat = 14

    var body: some View {
        ZStack {
            Circle()
                .stroke(tint.opacity(0.15), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0.001, min(fraction, 1)))
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int((fraction * 100).rounded()))%")
                .font(.system(.title2, design: .rounded).weight(.bold))
                .monospacedDigit()
        }
        .animation(.snappy, value: fraction)
    }
}
