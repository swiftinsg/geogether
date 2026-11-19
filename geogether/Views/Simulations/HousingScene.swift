import SwiftUI

struct HousingScene: View {
    let solutionCount: Int

    var body: some View {
        ZStack {
            Canvas { context, size in
                let w = size.width
                let h = size.height
                let groundY = h * 0.72
                let roadY = h * 0.82

                // 1. Sky transitions from dusty smog to crisp blue
                let skyTop = solutionCount >= 2
                    ? Color(red: 0.45, green: 0.80, blue: 0.99)
                    : Color(red: 0.74, green: 0.78, blue: 0.76)
                let skyBottom = solutionCount >= 2
                    ? Color(red: 0.88, green: 0.96, blue: 1.0)
                    : Color(red: 0.91, green: 0.88, blue: 0.79)

                context.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .linearGradient(
                        Gradient(colors: [skyTop, skyBottom]),
                        startPoint: .zero,
                        endPoint: CGPoint(x: 0, y: groundY)
                    )
                )

                // 2. Ground (barren dirt -> lush park grass at step 3)
                let groundColor = solutionCount >= 3
                    ? Color(red: 0.34, green: 0.70, blue: 0.34)
                    : Color(red: 0.65, green: 0.54, blue: 0.42)
                context.fill(
                    Path(CGRect(x: 0, y: groundY, width: w, height: h - groundY)),
                    with: .color(groundColor)
                )

                // 3. Roadway
                context.fill(
                    Path(CGRect(x: 0, y: roadY, width: w, height: h - roadY)),
                    with: .color(Color(red: 0.25, green: 0.28, blue: 0.32))
                )
                var roadLine = Path()
                roadLine.move(to: CGPoint(x: 0, y: roadY + (h - roadY) * 0.5))
                roadLine.addLine(to: CGPoint(x: w, y: roadY + (h - roadY) * 0.5))
                context.stroke(roadLine, with: .color(.white.opacity(0.65)), style: StrokeStyle(lineWidth: 2, dash: [12, 10]))

                // 4. Apartment Buildings (upgraded facades + solar panels & rainwater tanks at step 4)
                let buildingSpecs: [(x: CGFloat, width: CGFloat, height: CGFloat, color: Color)] = [
                    (w * 0.14, 54, 118, Color(red: 0.94, green: 0.84, blue: 0.70)),
                    (w * 0.32, 62, 145, Color(red: 0.88, green: 0.91, blue: 0.95)),
                    (w * 0.52, 58, 128, Color(red: 0.96, green: 0.89, blue: 0.78)),
                    (w * 0.70, 56, 138, Color(red: 0.85, green: 0.92, blue: 0.89))
                ]

                for (idx, spec) in buildingSpecs.enumerated() {
                    let rect = CGRect(x: spec.x, y: groundY - spec.height, width: spec.width, height: spec.height)
                    let wallColor = solutionCount >= 1 ? spec.color : spec.color.opacity(0.75)

                    context.fill(Path(roundedRect: rect, cornerRadius: 4), with: .color(wallColor))
                    context.fill(
                        Path(CGRect(x: rect.minX - 2, y: rect.minY - 4, width: rect.width + 4, height: 5)),
                        with: .color(AppPalette.navy)
                    )

                    // Windows
                    for r in 0..<4 {
                        for c in 0..<2 {
                            let wx = rect.minX + 10 + CGFloat(c) * (rect.width - 28)
                            let wy = rect.minY + 14 + CGFloat(r) * 24
                            let winColor = solutionCount >= 1
                                ? Color(red: 0.68, green: 0.89, blue: 0.98)
                                : Color(red: 0.35, green: 0.33, blue: 0.30)
                            context.fill(
                                Path(roundedRect: CGRect(x: wx, y: wy, width: 12, height: 14), cornerRadius: 2),
                                with: .color(winColor)
                            )
                        }
                    }

                    // Step 4: Rooftop Solar Panels & Rainwater Barrel
                    if solutionCount >= 4 {
                        var solar = Path()
                        solar.move(to: CGPoint(x: rect.minX + 8, y: rect.minY - 5))
                        solar.addLine(to: CGPoint(x: rect.maxX - 8, y: rect.minY - 15))
                        solar.addLine(to: CGPoint(x: rect.maxX - 8, y: rect.minY - 5))
                        solar.closeSubpath()
                        context.fill(solar, with: .color(Color(red: 0.12, green: 0.36, blue: 0.72)))

                        if idx.isMultiple(of: 2) {
                            let barrel = CGRect(x: rect.maxX + 2, y: groundY - 22, width: 12, height: 22)
                            context.fill(Path(roundedRect: barrel, cornerRadius: 3), with: .color(.blue))
                        }
                    }
                }

                // Step 1: Clean Waste Bins & Water Pipe Infrastructure (replaces trash clutter)
                if solutionCount == 0 {
                    // Litter / waste piles before cleanup
                    for i in 0..<5 {
                        let lx = 36 + CGFloat(i) * 42
                        context.fill(
                            Path(ellipseIn: CGRect(x: lx, y: groundY + 8, width: 14, height: 8)),
                            with: .color(Color(red: 0.42, green: 0.33, blue: 0.24))
                        )
                    }
                } else {
                    // Recycling & waste bins
                    let binColors: [Color] = [.green, .blue, .orange]
                    for (i, color) in binColors.enumerated() {
                        let bx = 24 + CGFloat(i) * 14
                        context.fill(
                            Path(roundedRect: CGRect(x: bx, y: groundY - 18, width: 10, height: 18), cornerRadius: 2),
                            with: .color(color)
                        )
                    }
                }

                // Step 2: Electric Bus & Bus Stop Shelter
                if solutionCount >= 2 {
                    let busRect = CGRect(x: w - 125, y: roadY - 24, width: 88, height: 34)
                    context.fill(Path(roundedRect: busRect, cornerRadius: 7), with: .color(.teal))
                    context.fill(
                        Path(roundedRect: CGRect(x: busRect.minX + 8, y: busRect.minY + 6, width: busRect.width - 16, height: 12), cornerRadius: 3),
                        with: .color(.white.opacity(0.85))
                    )
                    // Wheels
                    context.fill(Path(ellipseIn: CGRect(x: busRect.minX + 12, y: busRect.maxY - 6, width: 12, height: 12)), with: .color(.black))
                    context.fill(Path(ellipseIn: CGRect(x: busRect.maxX - 24, y: busRect.maxY - 6, width: 12, height: 12)), with: .color(.black))
                }

                // Step 3: Park Trees & Bench
                if solutionCount >= 3 {
                    let treeXs: [CGFloat] = [28, w - 34]
                    for tx in treeXs {
                        context.fill(
                            Path(CGRect(x: tx - 4, y: groundY - 26, width: 8, height: 26)),
                            with: .color(Color(red: 0.44, green: 0.29, blue: 0.16))
                        )
                        context.fill(
                            Path(ellipseIn: CGRect(x: tx - 22, y: groundY - 62, width: 44, height: 42)),
                            with: .color(Color(red: 0.16, green: 0.56, blue: 0.28))
                        )
                    }
                }

                // Step 4: Bright Sun
                if solutionCount >= 4 {
                    let sun = CGPoint(x: w - 48, y: 46)
                    context.drawLayer { layer in
                        layer.addFilter(.shadow(color: .yellow.opacity(0.65), radius: 14))
                        layer.fill(
                            Path(ellipseIn: CGRect(x: sun.x - 20, y: sun.y - 20, width: 40, height: 40)),
                            with: .color(.yellow)
                        )
                    }
                }
            }

            if solutionCount >= 1 {
                Label("Clean water", systemImage: "drop.fill")
                    .sceneChip(color: .blue)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(14)
            }
            if solutionCount >= 2 {
                Label("Bus link", systemImage: "bus.fill")
                    .sceneChip(color: .purple)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(.top, 52)
                    .padding(.trailing, 14)
            }

            CatCharacter(
                accessory: solutionCount >= 2 ? "heart.fill" : "exclamationmark.triangle.fill",
                tint: solutionCount >= 2 ? .green : .orange
            )
            .frame(width: 80, height: 86)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            .padding(.leading, 16)
            .padding(.bottom, 12)
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.72), value: solutionCount)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Neighbourhood with \(solutionCount) of 4 improvements")
    }
}

private extension View {
    func sceneChip(color: Color) -> some View {
        font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(color))
    }
}
