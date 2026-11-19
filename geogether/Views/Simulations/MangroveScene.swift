import SwiftUI

struct MangroveScene: View {
    let rootType: String
    let pulse: Bool

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let waterY = h * 0.64
            let mudY = h * 0.80

            // 1. Coastal Sky
            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .linearGradient(
                    Gradient(colors: [
                        Color(red: 0.55, green: 0.86, blue: 0.96),
                        Color(red: 0.84, green: 0.95, blue: 0.92)
                    ]),
                    startPoint: .zero,
                    endPoint: CGPoint(x: 0, y: waterY)
                )
            )

            // Distant shoreline silhouettes
            var distantLand = Path()
            distantLand.move(to: CGPoint(x: 0, y: waterY))
            distantLand.addQuadCurve(to: CGPoint(x: w * 0.45, y: waterY - 14), control: CGPoint(x: w * 0.2, y: waterY - 22))
            distantLand.addQuadCurve(to: CGPoint(x: w, y: waterY), control: CGPoint(x: w * 0.78, y: waterY - 18))
            distantLand.closeSubpath()
            context.fill(distantLand, with: .color(Color(red: 0.38, green: 0.67, blue: 0.55).opacity(0.45)))

            // 2. Organic Tree Canopy (layered leafy clusters instead of a single icon)
            let canopyCenter = CGPoint(x: w * 0.5, y: h * 0.25)
            let foliageClusters: [(dx: CGFloat, dy: CGFloat, rx: CGFloat, ry: CGFloat, color: Color)] = [
                (-65, 12, 62, 44, Color(red: 0.11, green: 0.44, blue: 0.22)),
                (68, 14, 60, 42, Color(red: 0.11, green: 0.44, blue: 0.22)),
                (0, -18, 86, 54, Color(red: 0.15, green: 0.54, blue: 0.27)),
                (-38, -4, 58, 42, Color(red: 0.20, green: 0.61, blue: 0.31)),
                (40, -2, 56, 40, Color(red: 0.18, green: 0.58, blue: 0.29))
            ]

            // 3. Tapered Trunk & Upper Branches
            var trunk = Path()
            trunk.move(to: CGPoint(x: w * 0.5 - 15, y: h * 0.58))
            trunk.addQuadCurve(to: CGPoint(x: w * 0.5 - 10, y: h * 0.28), control: CGPoint(x: w * 0.5 - 13, y: h * 0.43))
            trunk.addLine(to: CGPoint(x: w * 0.5 - 48, y: h * 0.22))
            trunk.addLine(to: CGPoint(x: w * 0.5 - 42, y: h * 0.18))
            trunk.addLine(to: CGPoint(x: w * 0.5, y: h * 0.25))
            trunk.addLine(to: CGPoint(x: w * 0.5 + 45, y: h * 0.19))
            trunk.addLine(to: CGPoint(x: w * 0.5 + 50, y: h * 0.24))
            trunk.addLine(to: CGPoint(x: w * 0.5 + 10, y: h * 0.29))
            trunk.addQuadCurve(to: CGPoint(x: w * 0.5 + 15, y: h * 0.58), control: CGPoint(x: w * 0.5 + 13, y: h * 0.43))
            trunk.closeSubpath()
            context.fill(trunk, with: .color(Color(red: 0.38, green: 0.25, blue: 0.15)))

            // Draw foliage over branches
            for cluster in foliageClusters {
                let rect = CGRect(
                    x: canopyCenter.x + cluster.dx - cluster.rx,
                    y: canopyCenter.y + cluster.dy - cluster.ry,
                    width: cluster.rx * 2,
                    height: cluster.ry * 2
                )
                context.fill(Path(ellipseIn: rect), with: .color(cluster.color))
            }

            // 4. Water Layer
            var water = Path()
            water.move(to: CGPoint(x: 0, y: waterY))
            for step in 0...20 {
                let x = w * CGFloat(step) / 20
                let wave = sin(CGFloat(step) * 0.9) * 2.5
                water.addLine(to: CGPoint(x: x, y: waterY + wave))
            }
            water.addLine(to: CGPoint(x: w, y: mudY))
            water.addLine(to: CGPoint(x: 0, y: mudY))
            water.closeSubpath()
            context.fill(
                water,
                with: .linearGradient(
                    Gradient(colors: [
                        Color(red: 0.22, green: 0.66, blue: 0.74).opacity(0.62),
                        Color(red: 0.16, green: 0.50, blue: 0.58).opacity(0.78)
                    ]),
                    startPoint: CGPoint(x: 0, y: waterY),
                    endPoint: CGPoint(x: 0, y: mudY)
                )
            )

            // 5. Mud / Sediment Cross-Section
            let mudRect = CGRect(x: 0, y: mudY, width: w, height: h - mudY)
            context.fill(
                Path(mudRect),
                with: .linearGradient(
                    Gradient(colors: [
                        Color(red: 0.40, green: 0.28, blue: 0.18),
                        Color(red: 0.29, green: 0.19, blue: 0.12)
                    ]),
                    startPoint: CGPoint(x: 0, y: mudY),
                    endPoint: CGPoint(x: 0, y: h)
                )
            )

            // Small pebbles/shells in mud for cross-section realism
            for i in 0..<14 {
                let px = 22 + CGFloat(i) * (w - 44) / 13
                let py = mudY + 14 + CGFloat(i % 3) * 16
                context.fill(
                    Path(ellipseIn: CGRect(x: px, y: py, width: 7, height: 4)),
                    with: .color(Color.white.opacity(0.14))
                )
            }

            // 6. Root Systems (with subtle pulse scale)
            let scale: CGFloat = pulse ? 1.07 : 1.0
            let darkBark = Color(red: 0.34, green: 0.21, blue: 0.11)
            let lightBark = Color(red: 0.49, green: 0.33, blue: 0.19)

            if rootType == "Prop roots" {
                let offsets: [CGFloat] = [-108, -74, -40, 0, 40, 74, 108]
                for (idx, rawOffset) in offsets.enumerated() {
                    let offset = rawOffset * scale
                    let startY = h * (0.48 + CGFloat(abs(idx - 3)) * 0.025)
                    var root = Path()
                    root.move(to: CGPoint(x: w * 0.5 + rawOffset * 0.08, y: startY))
                    root.addQuadCurve(
                        to: CGPoint(x: w * 0.5 + offset, y: mudY + 18),
                        control: CGPoint(x: w * 0.5 + offset * 0.85, y: h * 0.62)
                    )
                    context.stroke(root, with: .color(darkBark), style: StrokeStyle(lineWidth: 9.5, lineCap: .round))
                    context.stroke(root, with: .color(lightBark), style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                }
            } else if rootType == "Breathing roots" {
                // Horizontal cable root beneath the mud
                var cable = Path()
                cable.move(to: CGPoint(x: 24, y: mudY + 18))
                cable.addLine(to: CGPoint(x: w - 24, y: mudY + 18))
                context.stroke(cable, with: .color(darkBark), style: StrokeStyle(lineWidth: 8, lineCap: .round))

                // Vertical pencil-like pneumatophores rising above water
                for i in 0..<13 {
                    let x = 32 + CGFloat(i) * (w - 64) / 12
                    let tipY = waterY - CGFloat(14 + (i % 3) * 9) * scale
                    var stalk = Path()
                    stalk.move(to: CGPoint(x: x, y: mudY + 16))
                    stalk.addLine(to: CGPoint(x: x, y: tipY))
                    context.stroke(stalk, with: .color(lightBark), style: StrokeStyle(lineWidth: 6.5, lineCap: .round))

                    // Oxygen breathing pores (lenticels)
                    context.fill(
                        Path(ellipseIn: CGRect(x: x - 1.5, y: tipY + 6, width: 3, height: 3)),
                        with: .color(.white.opacity(0.65))
                    )
                }
            } else {
                // Knee roots looping up above the water/mud and back down
                for i in 0..<5 {
                    let startX = 36 + CGFloat(i) * (w - 110) / 4
                    let loopWidth: CGFloat = 46
                    let peakY = waterY - CGFloat(16 + (i % 2) * 8) * scale

                    var knee = Path()
                    knee.move(to: CGPoint(x: startX, y: mudY + 16))
                    knee.addQuadCurve(
                        to: CGPoint(x: startX + loopWidth, y: mudY + 16),
                        control: CGPoint(x: startX + loopWidth / 2, y: peakY)
                    )
                    context.stroke(knee, with: .color(darkBark), style: StrokeStyle(lineWidth: 9, lineCap: .round))
                    context.stroke(knee, with: .color(lightBark), style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.6), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.14), radius: 10, y: 5)
    }
}
