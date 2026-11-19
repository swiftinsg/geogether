import SwiftUI

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
