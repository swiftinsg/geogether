import SwiftUI

struct SettlementScene: View {
    let level: Int
    let buildingCount: Int

    var body: some View {
        ZStack {
            Canvas { context, size in
                let w = size.width
                let h = size.height

                // Sky (shifts slightly warmer/hazier as urban density grows)
                let haze = Double(level) / 6.0 * 0.12
                context.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .linearGradient(
                        Gradient(colors: [
                            Color(red: 0.45 + haze, green: 0.78, blue: 0.98 - haze),
                            Color(red: 0.88, green: 0.95, blue: 1.0)
                        ]),
                        startPoint: .zero,
                        endPoint: CGPoint(x: 0, y: h)
                    )
                )

                // Soft Sun
                let sunCenter = CGPoint(x: w * 0.83, y: h * 0.17)
                context.drawLayer { layer in
                    layer.addFilter(.shadow(color: .yellow.opacity(0.55), radius: 16))
                    layer.fill(
                        Path(ellipseIn: CGRect(x: sunCenter.x - 22, y: sunCenter.y - 22, width: 44, height: 44)),
                        with: .color(Color(red: 1.0, green: 0.93, blue: 0.55))
                    )
                }

                // Distant Rolling Hills
                var backHill = Path()
                backHill.move(to: CGPoint(x: 0, y: h * 0.65))
                backHill.addQuadCurve(to: CGPoint(x: w * 0.58, y: h * 0.62), control: CGPoint(x: w * 0.28, y: h * 0.48))
                backHill.addQuadCurve(to: CGPoint(x: w, y: h * 0.66), control: CGPoint(x: w * 0.82, y: h * 0.53))
                backHill.addLine(to: CGPoint(x: w, y: h))
                backHill.addLine(to: CGPoint(x: 0, y: h))
                backHill.closeSubpath()
                context.fill(backHill, with: .color(Color(red: 0.48, green: 0.75, blue: 0.46)))

                // Midground Valley
                var frontHill = Path()
                frontHill.move(to: CGPoint(x: 0, y: h * 0.70))
                frontHill.addCurve(
                    to: CGPoint(x: w, y: h * 0.68),
                    control1: CGPoint(x: w * 0.35, y: h * 0.76),
                    control2: CGPoint(x: w * 0.68, y: h * 0.62)
                )
                frontHill.addLine(to: CGPoint(x: w, y: h))
                frontHill.addLine(to: CGPoint(x: 0, y: h))
                frontHill.closeSubpath()
                context.fill(frontHill, with: .color(Color(red: 0.33, green: 0.65, blue: 0.32)))

                // Dirt path for levels 0 to 2, paved road for level 3 and above
                let groundY = h * 0.84
                if level < 3 {
                    var dirtPath = Path()
                    dirtPath.move(to: CGPoint(x: w * 0.12, y: h))
                    dirtPath.addQuadCurve(
                        to: CGPoint(x: w * 0.52, y: groundY - 4),
                        control: CGPoint(x: w * 0.28, y: h * 0.88)
                    )
                    context.stroke(
                        dirtPath,
                        with: .color(Color(red: 0.76, green: 0.65, blue: 0.46)),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                } else {
                    let roadRect = CGRect(x: 0, y: groundY, width: w, height: h - groundY)
                    context.fill(Path(roadRect), with: .color(Color(red: 0.24, green: 0.27, blue: 0.31)))

                    // Sidewalk curb
                    context.fill(
                        Path(CGRect(x: 0, y: groundY, width: w, height: 5)),
                        with: .color(Color(red: 0.78, green: 0.80, blue: 0.82))
                    )

                    // Dashed lane markings
                    var lane = Path()
                    let laneY = groundY + (h - groundY) * 0.48
                    lane.move(to: CGPoint(x: 0, y: laneY))
                    lane.addLine(to: CGPoint(x: w, y: laneY))
                    context.stroke(
                        lane,
                        with: .color(.white.opacity(0.75)),
                        style: StrokeStyle(lineWidth: 2, dash: [14, 12])
                    )
                }

                // Back Skyline Row (for Large Town, City, Conurbation)
                if level >= 4 {
                    let towerCount = level == 4 ? 5 : (level == 5 ? 8 : 12)
                    let spacing = (w - 40) / CGFloat(towerCount)
                    for i in 0..<towerCount {
                        let seed = sin(Double(i) * 19.3 + Double(level))
                        let bWidth = spacing * (level == 6 ? 0.92 : 0.78)
                        let bHeight = CGFloat(65 + abs(seed) * (level == 6 ? 115 : 75))
                        let x = 20 + CGFloat(i) * spacing
                        let y = groundY - bHeight
                        drawSkyscraper(
                            context: &context,
                            rect: CGRect(x: x, y: y, width: bWidth, height: bHeight),
                            seed: i + level,
                            isConurbation: level == 6
                        )
                    }
                }

                // Foreground Houses / Shops
                let fgCount = min(buildingCount, level >= 4 ? 7 : buildingCount)
                let usableWidth = w - 115 // leave room for CatCharacter on the left
                let step = usableWidth / CGFloat(max(fgCount, 1))

                for i in 0..<fgCount {
                    let centerX = 98 + step * (CGFloat(i) + 0.5)
                    let isShop = level >= 2 && i.isMultiple(of: 3)
                    let houseW: CGFloat = level >= 3 ? 34 : 40
                    let houseH: CGFloat = isShop ? 38 : 28
                    let rect = CGRect(x: centerX - houseW / 2, y: groundY - houseH, width: houseW, height: houseH)

                    if isShop {
                        drawShopfront(context: &context, rect: rect, index: i)
                    } else {
                        drawCottage(context: &context, rect: rect, index: i)
                    }
                }

                // Rural Trees when density is low
                if level <= 4 {
                    let treePositions: [CGFloat] = level <= 1 ? [0.28, 0.72, 0.86] : [0.88]
                    for tx in treePositions {
                        drawPineTree(context: &context, base: CGPoint(x: w * tx, y: groundY), scale: 0.9)
                    }
                }
            }

            CatCharacter(accessory: level >= 3 ? "briefcase.fill" : "leaf.fill", tint: .teal)
                .frame(width: 72, height: 78)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding(.leading, 14)
                .padding(.bottom, 10)
        }
        .animation(.snappy, value: level)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Settlement with \(buildingCount) buildings")
    }

    private func drawCottage(context: inout GraphicsContext, rect: CGRect, index: Int) {
        let wallColors = [
            Color(red: 0.98, green: 0.95, blue: 0.88),
            Color(red: 0.96, green: 0.89, blue: 0.78),
            Color(red: 0.91, green: 0.94, blue: 0.96)
        ]
        let roofColors = [
            Color(red: 0.76, green: 0.34, blue: 0.24),
            Color(red: 0.25, green: 0.35, blue: 0.48),
            Color(red: 0.64, green: 0.42, blue: 0.24)
        ]

        // Walls
        context.fill(
            Path(roundedRect: rect, cornerRadius: 2),
            with: .color(wallColors[index % wallColors.count])
        )

        // Pitched Roof
        var roof = Path()
        roof.move(to: CGPoint(x: rect.minX - 4, y: rect.minY))
        roof.addLine(to: CGPoint(x: rect.midX, y: rect.minY - 14))
        roof.addLine(to: CGPoint(x: rect.maxX + 4, y: rect.minY))
        roof.closeSubpath()
        context.fill(roof, with: .color(roofColors[index % roofColors.count]))

        // Door
        let doorW = rect.width * 0.22
        let doorH = rect.height * 0.46
        let door = CGRect(x: rect.midX - doorW / 2, y: rect.maxY - doorH, width: doorW, height: doorH)
        context.fill(Path(roundedRect: door, cornerRadius: 1.5), with: .color(AppPalette.navy))

        // Warm lit windows
        let winSize = rect.width * 0.18
        let leftWin = CGRect(x: rect.minX + 5, y: rect.minY + 7, width: winSize, height: winSize)
        let rightWin = CGRect(x: rect.maxX - 5 - winSize, y: rect.minY + 7, width: winSize, height: winSize)
        context.fill(Path(leftWin), with: .color(Color(red: 1.0, green: 0.86, blue: 0.42)))
        context.fill(Path(rightWin), with: .color(Color(red: 1.0, green: 0.86, blue: 0.42)))
    }

    private func drawShopfront(context: inout GraphicsContext, rect: CGRect, index: Int) {
        // Main facade
        context.fill(
            Path(roundedRect: rect, cornerRadius: 3),
            with: .color(Color(red: 0.93, green: 0.86, blue: 0.76))
        )
        // Roof parapet
        context.fill(
            Path(CGRect(x: rect.minX - 2, y: rect.minY - 4, width: rect.width + 4, height: 5)),
            with: .color(AppPalette.navy)
        )
        // Striped Awning
        let awningColor: Color = index.isMultiple(of: 2) ? .teal : .orange
        let awning = CGRect(x: rect.minX - 2, y: rect.midY - 2, width: rect.width + 4, height: 7)
        context.fill(Path(roundedRect: awning, cornerRadius: 2), with: .color(awningColor))

        // Display window
        let window = CGRect(x: rect.minX + 5, y: rect.midY + 7, width: rect.width - 10, height: rect.height * 0.32)
        context.fill(Path(roundedRect: window, cornerRadius: 2), with: .color(Color(red: 0.75, green: 0.91, blue: 0.98)))
    }

    private func drawSkyscraper(context: inout GraphicsContext, rect: CGRect, seed: Int, isConurbation: Bool) {
        let palette = [
            Color(red: 0.36, green: 0.49, blue: 0.62),
            Color(red: 0.45, green: 0.57, blue: 0.68),
            Color(red: 0.28, green: 0.39, blue: 0.52)
        ]
        context.fill(
            Path(roundedRect: rect, cornerRadius: 3),
            with: .color(palette[seed % palette.count])
        )

        // Spire on taller towers
        if seed.isMultiple(of: 3) {
            var spire = Path()
            spire.move(to: CGPoint(x: rect.midX, y: rect.minY))
            spire.addLine(to: CGPoint(x: rect.midX, y: rect.minY - 14))
            context.stroke(spire, with: .color(AppPalette.navy.opacity(0.7)), style: StrokeStyle(lineWidth: 2, lineCap: .round))
        }

        // Window grid
        let cols = max(2, Int(rect.width / 8))
        let rows = max(3, Int(rect.height / 11))
        let padX: CGFloat = 4
        let padY: CGFloat = 6
        let cellW = (rect.width - padX * 2) / CGFloat(cols)
        let cellH = (rect.height - padY * 2) / CGFloat(rows)

        for r in 0..<rows {
            for c in 0..<cols {
                let wx = rect.minX + padX + CGFloat(c) * cellW + 1.5
                let wy = rect.minY + padY + CGFloat(r) * cellH + 1.5
                let lit = (r + c + seed).isMultiple(of: isConurbation ? 2 : 3)
                let color = lit ? Color(red: 1.0, green: 0.90, blue: 0.52).opacity(0.85) : Color.white.opacity(0.25)
                context.fill(
                    Path(CGRect(x: wx, y: wy, width: max(2, cellW - 3), height: max(2, cellH - 4))),
                    with: .color(color)
                )
            }
        }
    }

    private func drawPineTree(context: inout GraphicsContext, base: CGPoint, scale: CGFloat) {
        // Trunk
        context.fill(
            Path(CGRect(x: base.x - 3 * scale, y: base.y - 12 * scale, width: 6 * scale, height: 12 * scale)),
            with: .color(Color(red: 0.42, green: 0.28, blue: 0.16))
        )
        // Two foliage tiers
        for tier in 0..<2 {
            let yOffset = CGFloat(tier) * 12 * scale
            let halfW = (15 - CGFloat(tier) * 3) * scale
            var tri = Path()
            tri.move(to: CGPoint(x: base.x, y: base.y - (32 + yOffset) * scale))
            tri.addLine(to: CGPoint(x: base.x - halfW, y: base.y - (10 + yOffset) * scale))
            tri.addLine(to: CGPoint(x: base.x + halfW, y: base.y - (10 + yOffset) * scale))
            tri.closeSubpath()
            context.fill(tri, with: .color(Color(red: 0.16, green: 0.48, blue: 0.24)))
        }
    }
}
