import SwiftUI

enum AppPalette {
    static let navy = Color(red: 0.0, green: 0.25, blue: 0.55)
    static let blue = Color(red: 0.0, green: 0.30, blue: 0.70)
}

/// Moving blue background shared by the welcome and exploration screens.
struct AnimatedOceanBackground: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let pulse = (sin(time * 0.9) + 1) / 2
            let sway = sin(time * 0.7)

            LinearGradient(
                colors: [
                    Color(red: 0.40 + 0.25 * pulse, green: 0.72 + 0.18 * pulse, blue: 1),
                    Color(red: 0.10 + 0.25 * pulse, green: 0.70 + 0.15 * pulse, blue: 0.95),
                    Color(red: 0.80, green: 0.94, blue: 1)
                ],
                startPoint: UnitPoint(x: 0.5 + 0.6 * sway, y: 0),
                endPoint: UnitPoint(x: 0.5 - 0.6 * sway, y: 1)
            )
        }
        .ignoresSafeArea()
    }
}

/// Soft background that echoes the colour of the current topic.
struct AppBackground: View {
    var tint: Color = TopicTint.teal.color

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
            RadialGradient(
                colors: [tint.opacity(0.20), tint.opacity(0.05), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 560
            )
        }
        .ignoresSafeArea()
    }
}

/// A white, rounded card used across the app.
struct QuizCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 18, y: 8)
    }
}

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

/// Small numbered capsule, used for ordering answers.
struct NumberBadge: View {
    let number: Int
    let tint: Color

    var body: some View {
        Text("\(number)")
            .font(.caption.weight(.bold))
            .foregroundStyle(tint)
            .frame(width: 22, height: 22)
            .background(Circle().fill(tint.opacity(0.18)))
    }
}

enum Keyboard {
    static func dismiss() {
        #if canImport(UIKit)
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
        #endif
    }
}
