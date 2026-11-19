import SwiftUI

enum WaterCycleRenderer {
    static func draw(
        context: inout GraphicsContext,
        size: CGSize,
        particles: [WaterCycleEngine.Particle],
        cloudMoisture: CGFloat,
        phase: WaterCycleEngine.Phase,
        time: TimeInterval
    ) {
        drawSky(context: &context, size: size)
        drawSun(context: &context, size: size, time: time)
        drawLand(context: &context, size: size)
        drawOcean(context: &context, size: size, time: time)
        drawStream(context: &context, size: size, time: time)
        drawHeatShimmer(context: &context, size: size, time: time)
        drawFlowGuides(context: &context, size: size, phase: phase, time: time)
        drawParticles(context: &context, size: size, particles: particles)
        drawCloud(context: &context, size: size, moisture: cloudMoisture, time: time)
    }

    private static func drawSky(context: inout GraphicsContext, size: CGSize) {
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.47, green: 0.77, blue: 0.98),
                    Color(red: 0.86, green: 0.95, blue: 1)
                ]),
                startPoint: .zero,
                endPoint: CGPoint(x: 0, y: size.height)
            )
        )
    }

    private static func drawSun(context: inout GraphicsContext, size: CGSize, time: TimeInterval) {
        let center = point(0.84, 0.16, size)
        let pulse = CGFloat((sin(time * 2.2) + 1) / 2)
        let radius = min(size.width, size.height) * (0.055 + pulse * 0.005)

        context.drawLayer { layer in
            layer.addFilter(.shadow(color: .yellow.opacity(0.65), radius: 18 + pulse * 8))
            layer.fill(
                Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)),
                with: .radialGradient(
                    Gradient(colors: [.white, .yellow, .orange]),
                    center: center,
                    startRadius: 0,
                    endRadius: radius
                )
            )
        }

        var rays = Path()
        for index in 0..<12 {
            let angle = CGFloat(index) / 12 * .pi * 2 + CGFloat(time * 0.18)
            let inner = radius * 1.30
            let outer = radius * (1.70 + pulse * 0.20)
            rays.move(to: CGPoint(x: center.x + cos(angle) * inner, y: center.y + sin(angle) * inner))
            rays.addLine(to: CGPoint(x: center.x + cos(angle) * outer, y: center.y + sin(angle) * outer))
        }
        context.stroke(rays, with: .color(.yellow.opacity(0.76)), style: StrokeStyle(lineWidth: 3, lineCap: .round))
    }

    private static func drawLand(context: inout GraphicsContext, size: CGSize) {
        var land = Path()
        land.move(to: CGPoint(x: 0, y: size.height * 0.42))
        land.addCurve(to: point(0.56, 0.74, size), control1: point(0.18, 0.46, size), control2: point(0.35, 0.68, size))
        land.addLine(to: CGPoint(x: size.width * 0.64, y: size.height))
        land.addLine(to: CGPoint(x: 0, y: size.height))
        land.closeSubpath()
        context.fill(
            land,
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.27, green: 0.62, blue: 0.29),
                    Color(red: 0.56, green: 0.74, blue: 0.32),
                    Color(red: 0.83, green: 0.71, blue: 0.43)
                ]),
                startPoint: point(0.05, 0.42, size),
                endPoint: point(0.58, 0.92, size)
            )
        )
    }

    private static func drawOcean(context: inout GraphicsContext, size: CGSize, time: TimeInterval) {
        let surface = size.height * 0.73
        var ocean = Path()
        ocean.move(to: CGPoint(x: size.width * 0.50, y: surface))
        for step in 0...24 {
            let x = size.width * (0.50 + CGFloat(step) / 48)
            ocean.addLine(to: CGPoint(x: x, y: surface + sin(CGFloat(step) * 0.95 + CGFloat(time * 2.1)) * 3.5))
        }
        ocean.addLine(to: CGPoint(x: size.width, y: size.height))
        ocean.addLine(to: CGPoint(x: size.width * 0.50, y: size.height))
        ocean.closeSubpath()
        context.fill(
            ocean,
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.03, green: 0.53, blue: 0.84),
                    Color(red: 0.01, green: 0.24, blue: 0.62),
                    Color(red: 0.01, green: 0.12, blue: 0.40)
                ]),
                startPoint: CGPoint(x: 0, y: surface),
                endPoint: CGPoint(x: 0, y: size.height)
            )
        )

        for band in 0..<4 {
            var wave = Path()
            let y = surface + CGFloat(12 + band * 15)
            wave.move(to: CGPoint(x: size.width * 0.51, y: y))
            for step in 0...20 {
                let x = size.width * (0.51 + CGFloat(step) / 40)
                wave.addLine(to: CGPoint(x: x, y: y + sin(CGFloat(step) * 0.85 + CGFloat(time * 1.8) + CGFloat(band)) * 2.5))
            }
            context.stroke(wave, with: .color(.cyan.opacity(0.34)), style: StrokeStyle(lineWidth: 1.4))
        }
    }

    private static func drawStream(context: inout GraphicsContext, size: CGSize, time: TimeInterval) {
        var stream = Path()
        stream.move(to: point(0.07, 0.49, size))
        stream.addCurve(to: point(0.31, 0.63, size), control1: point(0.19, 0.50, size), control2: point(0.20, 0.62, size))
        stream.addCurve(to: point(0.57, 0.75, size), control1: point(0.43, 0.64, size), control2: point(0.45, 0.75, size))
        context.stroke(
            stream,
            with: .color(.cyan.opacity(0.88)),
            style: StrokeStyle(lineWidth: 7, lineCap: .round, dash: [18, 8], dashPhase: CGFloat(time * -24))
        )
        context.stroke(stream, with: .color(.white.opacity(0.50)), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
    }

    private static func drawHeatShimmer(context: inout GraphicsContext, size: CGSize, time: TimeInterval) {
        for index in 0..<5 {
            var ripple = Path()
            let x = size.width * (0.67 + CGFloat(index) * 0.055)
            let y = size.height * (0.68 - CGFloat(index % 2) * 0.025)
            ripple.move(to: CGPoint(x: x, y: y))
            ripple.addCurve(
                to: CGPoint(x: x + 12, y: y - 35),
                control1: CGPoint(x: x - 9 + sin(CGFloat(time * 2) + CGFloat(index)) * 3, y: y - 12),
                control2: CGPoint(x: x + 18, y: y - 24)
            )
            context.stroke(ripple, with: .color(.white.opacity(0.22)), style: StrokeStyle(lineWidth: 2, lineCap: .round))
        }
    }

    private static func drawFlowGuides(
        context: inout GraphicsContext,
        size: CGSize,
        phase: WaterCycleEngine.Phase,
        time: TimeInterval
    ) {
        var evaporation = Path()
        evaporation.move(to: point(0.76, 0.68, size))
        evaporation.addCurve(to: point(0.53, 0.31, size), control1: point(0.83, 0.50, size), control2: point(0.70, 0.34, size))
        context.stroke(
            evaporation,
            with: .color(.white.opacity(phase == .evaporation ? 0.88 : 0.34)),
            style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [7, 7], dashPhase: CGFloat(time * -18))
        )

        var returnArrow = Path()
        returnArrow.move(to: point(0.35, 0.68, size))
        returnArrow.addCurve(to: point(0.61, 0.75, size), control1: point(0.44, 0.67, size), control2: point(0.50, 0.75, size))
        returnArrow.addLine(to: point(0.58, 0.72, size))
        returnArrow.move(to: point(0.61, 0.75, size))
        returnArrow.addLine(to: point(0.57, 0.77, size))
        context.stroke(
            returnArrow,
            with: .color(.cyan.opacity(phase == .collection ? 0.95 : 0.35)),
            style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
        )
    }

    private static func drawParticles(
        context: inout GraphicsContext,
        size: CGSize,
        particles: [WaterCycleEngine.Particle]
    ) {
        for particle in particles {
            switch particle.state {
            case .sea:
                guard particle.id % 8 == 0 else { continue }
                let position = point(0.54 + particle.lane * 0.43, 0.77 + particle.offset * 0.19, size)
                drawDroplet(context: &context, at: position, radius: 1.5, color: .cyan.opacity(0.34))
            case .vapor:
                let start = point(0.66 + particle.lane * 0.29, 0.73 + particle.offset * 0.02, size)
                let control = point(0.78 - particle.lane * 0.12, 0.34 - particle.offset * 0.06, size)
                let end = point(0.35 + particle.lane * 0.20, 0.25 + particle.offset * 0.035, size)
                drawDroplet(
                    context: &context,
                    at: quadratic(start, control, end, particle.progress),
                    radius: 2.2 + particle.offset * 2.2,
                    color: .white.opacity(0.82)
                )
            case .cloud:
                guard particle.id % 12 == 0 else { continue }
                let position = point(0.34 + particle.lane * 0.21, 0.19 + particle.offset * 0.12, size)
                drawDroplet(context: &context, at: position, radius: 1.3, color: .white.opacity(0.50))
            case .rain:
                let start = point(0.30 + particle.lane * 0.29, 0.29 + particle.offset * 0.045, size)
                let endX = particle.lane < 0.68 ? 0.08 + particle.lane * 0.64 : 0.53 + particle.lane * 0.24
                let position = linear(start, point(endX, 0.72 + particle.offset * 0.10, size), particle.progress)
                var streak = Path()
                streak.move(to: CGPoint(x: position.x + 4, y: position.y - 7))
                streak.addLine(to: CGPoint(x: position.x - 2, y: position.y + 7))
                context.stroke(streak, with: .color(.cyan.opacity(0.90)), style: StrokeStyle(lineWidth: 1.7, lineCap: .round))
            case .runoff:
                let start = point(0.10 + particle.lane * 0.43, 0.52 + particle.lane * 0.20, size)
                let control = point(0.34, 0.67 + particle.offset * 0.05, size)
                let end = point(0.59, 0.75, size)
                drawDroplet(context: &context, at: quadratic(start, control, end, particle.progress), radius: 2.2, color: .cyan.opacity(0.88))
            }
        }
    }

    private static func drawCloud(
        context: inout GraphicsContext,
        size: CGSize,
        moisture: CGFloat,
        time: TimeInterval
    ) {
        let scale = 0.60 + moisture * 0.85
        let center = point(0.42, 0.23, size)
        let baseRadius = min(size.width, size.height) * 0.075 * scale
        let puffCount = 4 + Int((moisture * 8).rounded(.down))
        let storm = Color(
            red: 0.94 - moisture * 0.56,
            green: 0.97 - moisture * 0.49,
            blue: 1.00 - moisture * 0.32
        )

        context.drawLayer { layer in
            layer.addFilter(.shadow(color: .black.opacity(0.14 + moisture * 0.16), radius: 8, y: 5))
            for index in 0..<puffCount {
                let angle = CGFloat(index) / CGFloat(max(puffCount, 1)) * .pi * 2 + CGFloat(time * 0.06)
                let spreadX = cos(angle) * baseRadius * (0.75 + moisture * 0.30)
                let spreadY = sin(angle) * baseRadius * 0.38
                let radius = baseRadius * (0.66 + CGFloat(index % 3) * 0.13)
                let rect = CGRect(
                    x: center.x + spreadX - radius,
                    y: center.y + spreadY - radius,
                    width: radius * 2,
                    height: radius * 2
                )
                layer.fill(Path(ellipseIn: rect), with: .color(storm))
            }
            let base = CGRect(
                x: center.x - baseRadius * 1.55,
                y: center.y - baseRadius * 0.15,
                width: baseRadius * 3.1,
                height: baseRadius * 1.28
            )
            layer.fill(Path(roundedRect: base, cornerRadius: baseRadius * 0.62), with: .color(storm))
        }
    }

    private static func drawDroplet(
        context: inout GraphicsContext,
        at position: CGPoint,
        radius: CGFloat,
        color: Color
    ) {
        context.drawLayer { layer in
            layer.addFilter(.shadow(color: color, radius: radius * 1.8))
            layer.fill(
                Path(ellipseIn: CGRect(x: position.x - radius, y: position.y - radius, width: radius * 2, height: radius * 2)),
                with: .color(color)
            )
        }
    }

    private static func point(_ x: CGFloat, _ y: CGFloat, _ size: CGSize) -> CGPoint {
        CGPoint(x: x * size.width, y: y * size.height)
    }

    private static func linear(_ start: CGPoint, _ end: CGPoint, _ progress: CGFloat) -> CGPoint {
        CGPoint(x: start.x + (end.x - start.x) * progress, y: start.y + (end.y - start.y) * progress)
    }

    private static func quadratic(_ start: CGPoint, _ control: CGPoint, _ end: CGPoint, _ progress: CGFloat) -> CGPoint {
        let inverse = 1 - progress
        return CGPoint(
            x: inverse * inverse * start.x + 2 * inverse * progress * control.x + progress * progress * end.x,
            y: inverse * inverse * start.y + 2 * inverse * progress * control.y + progress * progress * end.y
        )
    }
}
