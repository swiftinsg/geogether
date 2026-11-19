import SwiftUI

struct RisingWaterView: View {
    let start: Date
    var fillAmount = 0.55
    var riseDuration = 2.4

    var body: some View {
        GeometryReader { geometry in
            TimelineView(.animation) { timeline in
                let elapsed = timeline.date.timeIntervalSince(start)
                let raw = min(max(elapsed / riseDuration, 0), 1)
                let level = fillAmount * (1 - pow(1 - raw, 3))
                let time = timeline.date.timeIntervalSinceReferenceDate

                ZStack {
                    WaterWaveShape(phase: time * 1.1, level: level * 0.96, amplitude: 15)
                        .fill(.cyan.opacity(0.35))
                    WaterWaveShape(phase: -time * 1.7, level: level, amplitude: 10)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.10, green: 0.55, blue: 0.95), AppPalette.blue],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    ForEach(0..<14, id: \.self) { index in
                        let xFraction = fraction(sin(Double(index) * 12.9898) * 43758.5453)
                        let speed = 0.10 + fraction(sin(Double(index) * 3.7) * 24634.6) * 0.10
                        let cycle = fraction(time * speed + xFraction * 7)
                        let waterTop = geometry.size.height * (1 - level)
                        let y = geometry.size.height - 12 - cycle * max(geometry.size.height - waterTop - 24, 0)

                        Circle()
                            .fill(.white.opacity(0.35 * (1 - cycle)))
                            .frame(width: 6 + xFraction * 12, height: 6 + xFraction * 12)
                            .position(
                                x: xFraction * geometry.size.width,
                                y: level > 0.03 ? y : geometry.size.height + 30
                            )
                    }
                }
            }
        }
    }

    private func fraction(_ value: Double) -> Double {
        value - floor(value)
    }
}

private struct WaterWaveShape: Shape {
    var phase: Double
    var level: Double
    var amplitude: Double

    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(phase, level) }
        set {
            phase = newValue.first
            level = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let surfaceY = rect.height * (1 - level)
        path.move(to: CGPoint(x: 0, y: surfaceY))

        for x in stride(from: CGFloat.zero, through: rect.width, by: 8) {
            let position = Double(x / rect.width)
            let y = surfaceY + CGFloat(sin(position * .pi * 4 + phase) * amplitude)
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}
