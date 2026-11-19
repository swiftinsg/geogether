import SwiftUI

// MARK: - 1. Settlement Hierarchy

struct SettlementHierarchyView: View {
    private struct Level {
        let name: String
        let population: String
        let services: String
        let buildings: Int
        let symbol: String
    }

    private let levels = [
        Level(name: "Isolated dwelling", population: "One household", services: "Residents travel elsewhere for most services.", buildings: 1, symbol: "house.fill"),
        Level(name: "Hamlet", population: "A few households", services: "Few or no permanent services.", buildings: 3, symbol: "house.fill"),
        Level(name: "Village", population: "Hundreds", services: "A shop, primary school or place of worship may serve the area.", buildings: 6, symbol: "house.lodge.fill"),
        Level(name: "Small town", population: "Thousands", services: "More shops, schools and local transport become available.", buildings: 10, symbol: "building.2.fill"),
        Level(name: "Large town", population: "Tens of thousands", services: "Residents can use hospitals, larger shops and more transport links.", buildings: 14, symbol: "building.2.fill"),
        Level(name: "City", population: "Hundreds of thousands", services: "Universities, specialist healthcare and major business districts serve a wide area.", buildings: 18, symbol: "building.columns.fill"),
        Level(name: "Conurbation", population: "Millions", services: "Several urban areas join to form one continuous built-up area.", buildings: 22, symbol: "building.2.crop.circle.fill")
    ]

    @State private var position = 0.0

    private var selectedIndex: Int { Int(position.rounded()) }
    private var selected: Level { levels[selectedIndex] }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Move the slider and watch the settlement grow.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                SettlementScene(level: selectedIndex, buildingCount: selected.buildings)
                    .frame(height: 330)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(.white.opacity(0.6), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.14), radius: 10, y: 5)

                VStack(spacing: 8) {
                    Slider(value: $position, in: 0...Double(levels.count - 1), step: 1)
                        .tint(.teal)
                    HStack {
                        Text("One home")
                        Spacer()
                        Text("Conurbation")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                QuizCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label(selected.name, systemImage: selected.symbol)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.teal)
                        Label(selected.population, systemImage: "person.3.fill")
                            .font(.subheadline.weight(.semibold))
                        Text(selected.services)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(20)
        }
        .background(AnimatedOceanBackground())
        .navigationTitle("Settlement hierarchy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct SettlementScene: View {
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

                // Dirt path (levels 0-2) or Paved Road (levels 3+)
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

// MARK: - 2. Mangrove Roots

struct MangroveRootsView: View {
    private enum RootType: String, CaseIterable, Identifiable {
        case prop = "Prop roots"
        case pneumatophore = "Breathing roots"
        case knee = "Knee roots"

        var id: Self { self }

        var detail: String {
            switch self {
            case .prop: return "Arching roots spread the tree's weight and hold it upright in soft mud."
            case .pneumatophore: return "Pencil-shaped roots grow above the waterlogged soil and take in oxygen through small pores."
            case .knee: return "Sections of root rise above the mud like knees. They help with gas exchange and stability."
            }
        }

        var prompt: String {
            switch self {
            case .prop: return "Tap the wide roots"
            case .pneumatophore: return "Tap the roots pointing up"
            case .knee: return "Tap a loop in the mud"
            }
        }
    }

    @State private var selection = RootType.prop
    @State private var pulse = false

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Picker("Root type", selection: $selection) {
                    ForEach(RootType.allCases) { root in
                        Text(root.rawValue).tag(root)
                    }
                }
                .pickerStyle(.segmented)

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.55)) {
                        pulse.toggle()
                    }
                } label: {
                    MangroveScene(rootType: selection.rawValue, pulse: pulse)
                        .frame(height: 380)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(selection.prompt)

                QuizCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(selection.prompt)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.green)
                        Text(selection.rawValue)
                            .font(.title3.weight(.bold))
                        Text(selection.detail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(20)
        }
        .background(AnimatedOceanBackground())
        .navigationTitle("Mangrove roots")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct MangroveScene: View {
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

// MARK: - 3. Sustainable Housing

struct HousingSolutionsView: View {
    @State private var progress = 0.0

    private var solutionCount: Int {
        min(4, Int((progress * 5).rounded(.down)))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Move the slider to improve the neighbourhood.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HousingScene(solutionCount: solutionCount)
                    .frame(height: 390)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(.white.opacity(0.6), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.14), radius: 10, y: 5)

                VStack(spacing: 8) {
                    Slider(value: $progress, in: 0...1)
                        .tint(.orange)
                    HStack {
                        Text("Housing problems")
                        Spacer()
                        Text("Sustainable community")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                QuizCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(solutionCount == 4 ? "The neighbourhood is ready" : "Add the next improvement")
                            .font(.headline)
                        if solutionCount == 0 {
                            Text(improvements[0])
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(Array(improvements.prefix(solutionCount).enumerated()), id: \.offset) { _, improvement in
                                Label(improvement, systemImage: "checkmark.circle.fill")
                                    .font(.subheadline)
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(AnimatedOceanBackground())
        .navigationTitle("Sustainable housing")
        .navigationBarTitleDisplayMode(.inline)
    }

    private let improvements = [
        "Safe waste and sewage disposal",
        "Reliable public transport",
        "Parks and shared spaces",
        "Solar power and rainwater collection"
    ]
}

private struct HousingScene: View {
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

// MARK: - Character & Helpers

struct CatCharacter: View {
    let accessory: String
    let tint: Color

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            ZStack {
                Triangle()
                    .fill(Color(red: 0.95, green: 0.76, blue: 0.48))
                    .frame(width: size * 0.30, height: size * 0.30)
                    .rotationEffect(.degrees(-18))
                    .offset(x: -size * 0.24, y: -size * 0.29)
                Triangle()
                    .fill(Color(red: 0.95, green: 0.76, blue: 0.48))
                    .frame(width: size * 0.30, height: size * 0.30)
                    .rotationEffect(.degrees(18))
                    .offset(x: size * 0.24, y: -size * 0.29)

                Circle()
                    .fill(Color(red: 0.95, green: 0.76, blue: 0.48))
                    .overlay {
                        VStack(spacing: size * 0.06) {
                            HStack(spacing: size * 0.19) {
                                Circle().frame(width: size * 0.06, height: size * 0.06)
                                Circle().frame(width: size * 0.06, height: size * 0.06)
                            }
                            Text("ω")
                                .font(.system(size: size * 0.19, weight: .medium, design: .rounded))
                        }
                        .foregroundStyle(AppPalette.navy)
                    }
                    .padding(size * 0.08)

                Image(systemName: accessory)
                    .font(.system(size: size * 0.20, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(size * 0.09)
                    .background(Circle().fill(tint))
                    .offset(x: size * 0.34, y: size * 0.31)
            }
        }
        .accessibilityHidden(true)
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
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

#Preview("Settlements") {
    NavigationStack { SettlementHierarchyView() }
}

#Preview("Mangroves") {
    NavigationStack { MangroveRootsView() }
}

#Preview("Housing") {
    NavigationStack { HousingSolutionsView() }
}
