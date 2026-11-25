import SwiftUI

struct MovingBlueBackground: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let lightBlue = Color(red: 0.74, green: 0.92, blue: 1.00)
    private let blue = Color(red: 0.32, green: 0.69, blue: 0.94)
    private let darkBlue = Color(red: 0.18, green: 0.50, blue: 0.80)

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60, paused: reduceMotion)) { context in
            let time = reduceMotion ? 0 : context.date.timeIntervalSinceReferenceDate * 1.8
            let phase = Float(time * .pi / 3)
            let horizontal = sin(phase) * 0.12
            let vertical = cos(phase * 0.8) * 0.12
            let blend = (sin(time * 0.7) + 1) / 2

            // Fixed perimeter points keep the screen covered while interior
            // points drift independently and colors flow between all edges.
            MeshGradient(
                width: 4,
                height: 4,
                points: [
                    [0, 0], [0.33, 0], [0.67, 0], [1, 0],
                    [0, 0.33],
                    [0.33 + horizontal, 0.33 + vertical],
                    [0.67 + vertical, 0.33 - horizontal],
                    [1, 0.33],
                    [0, 0.67],
                    [0.33 - vertical, 0.67 + horizontal],
                    [0.67 - horizontal, 0.67 - vertical],
                    [1, 0.67],
                    [0, 1], [0.33, 1], [0.67, 1], [1, 1]
                ],
                colors: [
                    darkBlue.mix(with: blue, by: blend), blue, lightBlue,
                    blue.mix(with: darkBlue, by: blend),
                    lightBlue.mix(with: blue, by: blend), darkBlue,
                    blue.mix(with: lightBlue, by: blend), lightBlue,
                    blue, lightBlue.mix(with: blue, by: blend), darkBlue,
                    blue.mix(with: darkBlue, by: blend),
                    darkBlue.mix(with: blue, by: blend), lightBlue, blue,
                    lightBlue.mix(with: darkBlue, by: blend)
                ],
                smoothsColors: true
            )
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
