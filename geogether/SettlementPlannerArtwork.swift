import SwiftUI

private let plannerInk = Color(red: 0.15, green: 0.17, blue: 0.15)

// MARK: - Feature artwork

struct SettlementFeatureView: View {
    let feature: SettlementFeature
    let cellSize: CGFloat

    var body: some View {
        Group {
            switch feature.artwork {
            case .school:
                SettlementSchoolArtwork()
            case .market:
                MarketArtwork()
            case .cafe:
                Image("SettlementCafe")
                    .resizable()
                    .scaledToFit()
            case .workshop:
                WorkshopArtwork()
            case .farm:
                FarmArtwork()
            case .office:
                OfficeArtwork()
            case .home:
                HomeArtwork(variant: feature.id == "home-a" ? 0 : 1)
            }
        }
        .frame(
            width: cellSize * feature.widthInCells,
            height: cellSize * feature.widthInCells * 0.88
        )
        .shadow(color: .black.opacity(0.10), radius: 1.5, y: 1)
        .accessibilityHidden(true)
    }
}

private struct SettlementSchoolArtwork: View {
    var body: some View {
        Canvas { context, size in
            context.scaleBy(x: size.width / 100, y: size.height / 100)

            context.fill(
                Path(ellipseIn: CGRect(x: 12, y: 82, width: 76, height: 10)),
                with: .color(.black.opacity(0.10))
            )

            let wall = CGRect(x: 17, y: 39, width: 66, height: 44)
            context.fill(Path(roundedRect: wall, cornerRadius: 3), with: .color(Color(red: 0.95, green: 0.89, blue: 0.75)))
            context.stroke(Path(roundedRect: wall, cornerRadius: 3), with: .color(plannerInk), lineWidth: 2.2)

            var roof = Path()
            roof.move(to: CGPoint(x: 12, y: 41))
            roof.addLine(to: CGPoint(x: 50, y: 15))
            roof.addLine(to: CGPoint(x: 88, y: 41))
            roof.closeSubpath()
            context.fill(roof, with: .color(Color(red: 0.71, green: 0.31, blue: 0.27)))
            context.stroke(roof, with: .color(plannerInk), lineWidth: 2.2)

            context.fill(Path(CGRect(x: 44, y: 62, width: 12, height: 21)), with: .color(Color(red: 0.27, green: 0.48, blue: 0.55)))
            context.stroke(Path(CGRect(x: 44, y: 62, width: 12, height: 21)), with: .color(plannerInk), lineWidth: 1.8)

            for x in [24.0, 62.0, 74.0] {
                let window = CGRect(x: x, y: 49, width: 10, height: 9)
                context.fill(Path(roundedRect: window, cornerRadius: 1), with: .color(Color(red: 0.67, green: 0.85, blue: 0.87)))
                context.stroke(Path(roundedRect: window, cornerRadius: 1), with: .color(plannerInk), lineWidth: 1.3)
            }

            context.stroke(Path(CGRect(x: 78, y: 13, width: 1.5, height: 26)), with: .color(plannerInk), lineWidth: 1.4)
            var flag = Path()
            flag.move(to: CGPoint(x: 79.5, y: 13))
            flag.addLine(to: CGPoint(x: 91, y: 17))
            flag.addLine(to: CGPoint(x: 79.5, y: 22))
            flag.closeSubpath()
            context.fill(flag, with: .color(Color(red: 0.91, green: 0.67, blue: 0.24)))

            context.draw(
                Text("SCHOOL")
                    .font(.system(size: 7.5, weight: .heavy, design: .rounded))
                    .foregroundColor(plannerInk),
                at: CGPoint(x: 50, y: 57)
            )
        }
    }
}

private struct MarketArtwork: View {
    var body: some View {
        Canvas { context, size in
            context.scaleBy(x: size.width / 100, y: size.height / 100)

            context.fill(
                Path(ellipseIn: CGRect(x: 10, y: 83, width: 80, height: 10)),
                with: .color(.black.opacity(0.10))
            )

            let awningColors = [
                Color(red: 0.85, green: 0.40, blue: 0.32),
                Color(red: 0.30, green: 0.59, blue: 0.55),
                Color(red: 0.89, green: 0.68, blue: 0.29)
            ]

            for index in 0..<3 {
                let x = CGFloat(8 + index * 30)
                let stall = CGRect(x: x, y: 43, width: 24, height: 38)
                context.fill(Path(roundedRect: stall, cornerRadius: 2), with: .color(Color(red: 0.94, green: 0.87, blue: 0.70)))
                context.stroke(Path(roundedRect: stall, cornerRadius: 2), with: .color(plannerInk), lineWidth: 1.8)

                let awning = CGRect(x: x - 2, y: 39, width: 28, height: 8)
                context.fill(Path(roundedRect: awning, cornerRadius: 2), with: .color(awningColors[index]))
                context.stroke(Path(roundedRect: awning, cornerRadius: 2), with: .color(plannerInk), lineWidth: 1.6)

                for stripe in 0..<3 {
                    let stripeX = x + 2 + CGFloat(stripe) * 8
                    context.stroke(
                        Path(CGRect(x: stripeX, y: 40, width: 1, height: 6)),
                        with: .color(.white.opacity(0.55)),
                        lineWidth: 1.5
                    )
                }

                context.fill(
                    Path(roundedRect: CGRect(x: x + 4, y: 55, width: 16, height: 13), cornerRadius: 2),
                    with: .color(Color(red: 0.67, green: 0.82, blue: 0.78))
                )
                context.fill(
                    Path(roundedRect: CGRect(x: x + 5, y: 70, width: 14, height: 4), cornerRadius: 1),
                    with: .color(Color(red: 0.55, green: 0.38, blue: 0.25))
                )
            }

            context.draw(
                Text("MARKET")
                    .font(.system(size: 7.5, weight: .heavy, design: .rounded))
                    .foregroundColor(plannerInk),
                at: CGPoint(x: 50, y: 29)
            )
        }
    }
}

private struct WorkshopArtwork: View {
    var body: some View {
        Canvas { context, size in
            context.scaleBy(x: size.width / 100, y: size.height / 100)

            context.fill(
                Path(ellipseIn: CGRect(x: 12, y: 82, width: 76, height: 10)),
                with: .color(.black.opacity(0.10))
            )

            let block = CGRect(x: 18, y: 46, width: 64, height: 38)
            context.fill(Path(roundedRect: block, cornerRadius: 2), with: .color(Color(red: 0.77, green: 0.79, blue: 0.76)))
            context.stroke(Path(roundedRect: block, cornerRadius: 2), with: .color(plannerInk), lineWidth: 2)

            var roof = Path()
            roof.move(to: CGPoint(x: 16, y: 47))
            for index in 0..<3 {
                let x = CGFloat(16 + index * 22)
                roof.addLine(to: CGPoint(x: x + 11, y: 32))
                roof.addLine(to: CGPoint(x: x + 22, y: 47))
            }
            roof.closeSubpath()
            context.fill(roof, with: .color(Color(red: 0.53, green: 0.57, blue: 0.55)))
            context.stroke(roof, with: .color(plannerInk), lineWidth: 2)

            let chimney = CGRect(x: 67, y: 22, width: 9, height: 24)
            context.fill(Path(roundedRect: chimney, cornerRadius: 1), with: .color(Color(red: 0.62, green: 0.52, blue: 0.45)))
            context.stroke(Path(roundedRect: chimney, cornerRadius: 1), with: .color(plannerInk), lineWidth: 1.8)

            for x in [27.0, 43.0, 59.0] {
                let window = CGRect(x: x, y: 56, width: 9, height: 9)
                context.fill(Path(window), with: .color(Color(red: 0.93, green: 0.80, blue: 0.47)))
                context.stroke(Path(window), with: .color(plannerInk), lineWidth: 1.2)
            }

            context.fill(Path(CGRect(x: 45, y: 69, width: 12, height: 15)), with: .color(Color(red: 0.38, green: 0.45, blue: 0.47)))
            context.stroke(Path(CGRect(x: 45, y: 69, width: 12, height: 15)), with: .color(plannerInk), lineWidth: 1.4)

            context.draw(
                Text("WORKS")
                    .font(.system(size: 7, weight: .heavy, design: .rounded))
                    .foregroundColor(plannerInk),
                at: CGPoint(x: 50, y: 43)
            )
        }
    }
}

private struct FarmArtwork: View {
    var body: some View {
        Canvas { context, size in
            context.scaleBy(x: size.width / 100, y: size.height / 100)

            context.fill(
                Path(ellipseIn: CGRect(x: 8, y: 82, width: 84, height: 10)),
                with: .color(.black.opacity(0.10))
            )

            let barn = CGRect(x: 12, y: 43, width: 56, height: 39)
            context.fill(Path(roundedRect: barn, cornerRadius: 2), with: .color(Color(red: 0.74, green: 0.33, blue: 0.27)))
            context.stroke(Path(roundedRect: barn, cornerRadius: 2), with: .color(plannerInk), lineWidth: 2)

            var roof = Path()
            roof.move(to: CGPoint(x: 8, y: 44))
            roof.addLine(to: CGPoint(x: 40, y: 20))
            roof.addLine(to: CGPoint(x: 72, y: 44))
            roof.closeSubpath()
            context.fill(roof, with: .color(Color(red: 0.53, green: 0.27, blue: 0.22)))
            context.stroke(roof, with: .color(plannerInk), lineWidth: 2)

            let door = CGRect(x: 31, y: 60, width: 18, height: 22)
            context.fill(Path(door), with: .color(Color(red: 0.94, green: 0.87, blue: 0.72)))
            context.stroke(Path(door), with: .color(plannerInk), lineWidth: 1.6)
            var cross = Path()
            cross.move(to: CGPoint(x: 31, y: 60))
            cross.addLine(to: CGPoint(x: 49, y: 82))
            cross.move(to: CGPoint(x: 49, y: 60))
            cross.addLine(to: CGPoint(x: 31, y: 82))
            context.stroke(cross, with: .color(plannerInk.opacity(0.65)), lineWidth: 1.2)

            let silo = CGRect(x: 70, y: 36, width: 16, height: 46)
            context.fill(Path(roundedRect: silo, cornerRadius: 4), with: .color(Color(red: 0.82, green: 0.80, blue: 0.70)))
            context.stroke(Path(roundedRect: silo, cornerRadius: 4), with: .color(plannerInk), lineWidth: 1.8)
            context.fill(
                Path(ellipseIn: CGRect(x: 70, y: 30, width: 16, height: 12)),
                with: .color(Color(red: 0.64, green: 0.66, blue: 0.61))
            )
            context.stroke(
                Path(ellipseIn: CGRect(x: 70, y: 30, width: 16, height: 12)),
                with: .color(plannerInk),
                lineWidth: 1.6
            )

            for y in [72.0, 78.0] {
                context.stroke(
                    Path(CGRect(x: 10, y: y, width: 62, height: 0.8)),
                    with: .color(Color(red: 0.42, green: 0.51, blue: 0.29)),
                    lineWidth: 1
                )
            }

            context.draw(
                Text("FARM")
                    .font(.system(size: 7, weight: .heavy, design: .rounded))
                    .foregroundColor(.white.opacity(0.9)),
                at: CGPoint(x: 40, y: 34)
            )
        }
    }
}

private struct OfficeArtwork: View {
    var body: some View {
        Canvas { context, size in
            context.scaleBy(x: size.width / 100, y: size.height / 100)

            context.fill(
                Path(ellipseIn: CGRect(x: 14, y: 82, width: 72, height: 9)),
                with: .color(.black.opacity(0.10))
            )

            let block = CGRect(x: 20, y: 30, width: 60, height: 54)
            context.fill(Path(roundedRect: block, cornerRadius: 3), with: .color(Color(red: 0.78, green: 0.84, blue: 0.82)))
            context.stroke(Path(roundedRect: block, cornerRadius: 3), with: .color(plannerInk), lineWidth: 2)

            context.fill(Path(CGRect(x: 18, y: 27, width: 64, height: 6)), with: .color(Color(red: 0.47, green: 0.55, blue: 0.54)))
            context.stroke(Path(CGRect(x: 18, y: 27, width: 64, height: 6)), with: .color(plannerInk), lineWidth: 1.6)

            for row in 0..<2 {
                for column in 0..<3 {
                    let window = CGRect(x: 26 + CGFloat(column) * 16, y: 39 + CGFloat(row) * 14, width: 10, height: 8)
                    context.fill(Path(window), with: .color(Color(red: 0.49, green: 0.72, blue: 0.78)))
                    context.stroke(Path(window), with: .color(plannerInk), lineWidth: 1.1)
                }
            }

            context.fill(Path(CGRect(x: 45, y: 66, width: 10, height: 18)), with: .color(Color(red: 0.30, green: 0.48, blue: 0.55)))
            context.stroke(Path(CGRect(x: 45, y: 66, width: 10, height: 18)), with: .color(plannerInk), lineWidth: 1.3)

            context.fill(
                Path(roundedRect: CGRect(x: 25, y: 20, width: 50, height: 10), cornerRadius: 3),
                with: .color(Color(red: 0.91, green: 0.86, blue: 0.68))
            )
            context.stroke(
                Path(roundedRect: CGRect(x: 25, y: 20, width: 50, height: 10), cornerRadius: 3),
                with: .color(plannerInk),
                lineWidth: 1.2
            )
            context.draw(
                Text("PLAN")
                    .font(.system(size: 6.5, weight: .heavy, design: .rounded))
                    .foregroundColor(plannerInk),
                at: CGPoint(x: 50, y: 25)
            )
        }
    }
}

struct HomeArtwork: View {
    var variant: Int = 0

    private var wallColor: Color {
        switch variant % 3 {
        case 0: Color(red: 0.97, green: 0.92, blue: 0.81)
        case 1: Color(red: 0.93, green: 0.88, blue: 0.78)
        default: Color(red: 0.88, green: 0.92, blue: 0.89)
        }
    }

    private var roofColor: Color {
        switch variant % 3 {
        case 0: Color(red: 0.72, green: 0.34, blue: 0.25)
        case 1: Color(red: 0.40, green: 0.48, blue: 0.56)
        default: Color(red: 0.62, green: 0.43, blue: 0.26)
        }
    }

    var body: some View {
        Canvas { context, size in
            context.scaleBy(x: size.width / 100, y: size.height / 100)

            context.fill(
                Path(ellipseIn: CGRect(x: 16, y: 82, width: 68, height: 9)),
                with: .color(.black.opacity(0.10))
            )

            let walls = CGRect(x: 24, y: 45, width: 52, height: 38)
            context.fill(Path(roundedRect: walls, cornerRadius: 2), with: .color(wallColor))
            context.stroke(Path(roundedRect: walls, cornerRadius: 2), with: .color(plannerInk), lineWidth: 2.2)

            var roof = Path()
            roof.move(to: CGPoint(x: 18, y: 46))
            roof.addLine(to: CGPoint(x: 50, y: 18))
            roof.addLine(to: CGPoint(x: 82, y: 46))
            roof.closeSubpath()
            context.fill(roof, with: .color(roofColor))
            context.stroke(roof, with: .color(plannerInk), lineWidth: 2.2)

            let door = CGRect(x: 44, y: 64, width: 12, height: 19)
            context.fill(Path(roundedRect: door, cornerRadius: 1), with: .color(Color(red: 0.25, green: 0.39, blue: 0.47)))
            context.stroke(Path(roundedRect: door, cornerRadius: 1), with: .color(plannerInk), lineWidth: 1.3)

            for x in [30.0, 61.0] {
                let window = CGRect(x: x, y: 53, width: 9, height: 9)
                context.fill(Path(window), with: .color(Color(red: 0.99, green: 0.85, blue: 0.44)))
                context.stroke(Path(window), with: .color(plannerInk), lineWidth: 1.2)
            }
        }
    }
}

// MARK: - Home cluster token

struct HomeClusterToken: View {
    var size: CGFloat = 64
    var isValid = true

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                .fill(.white.opacity(0.96))

            HomeArtwork(variant: 0)
                .frame(width: size * 0.44, height: size * 0.40)
                .offset(x: -size * 0.20, y: size * 0.10)
            HomeArtwork(variant: 1)
                .frame(width: size * 0.44, height: size * 0.40)
                .offset(x: size * 0.20, y: size * 0.10)
            HomeArtwork(variant: 2)
                .frame(width: size * 0.44, height: size * 0.40)
                .offset(x: 0, y: -size * 0.13)

            Text("3")
                .font(.system(size: size * 0.20, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: size * 0.28, height: size * 0.28)
                .background(
                    Circle().fill(isValid ? Color(red: 0.22, green: 0.52, blue: 0.36) : Color(red: 0.72, green: 0.25, blue: 0.22))
                )
                .offset(x: size * 0.34, y: -size * 0.34)
        }
        .frame(width: size, height: size)
        .overlay {
            RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                .strokeBorder(
                    isValid ? Color(red: 0.24, green: 0.50, blue: 0.34) : Color(red: 0.72, green: 0.25, blue: 0.22),
                    lineWidth: 2
                )
        }
        .shadow(color: .black.opacity(0.16), radius: size * 0.12, y: size * 0.06)
    }
}

// MARK: - Pattern glyph

struct PatternGlyph: View {
    let pattern: SettlementPattern
    var size: CGFloat = 44

    var body: some View {
        Canvas { context, size in
            let dot = min(size.width, size.height) * 0.15
            let points: [CGPoint]

            switch pattern {
            case .linear:
                points = [
                    CGPoint(x: size.width * 0.20, y: size.height * 0.52),
                    CGPoint(x: size.width * 0.50, y: size.height * 0.52),
                    CGPoint(x: size.width * 0.80, y: size.height * 0.52)
                ]
                var line = Path()
                line.move(to: CGPoint(x: size.width * 0.12, y: size.height * 0.52))
                line.addLine(to: CGPoint(x: size.width * 0.88, y: size.height * 0.52))
                context.stroke(
                    line,
                    with: .color(pattern.color.opacity(0.45)),
                    style: StrokeStyle(lineWidth: 1.5, dash: [3, 3])
                )
            case .nucleated:
                points = [
                    CGPoint(x: size.width * 0.50, y: size.height * 0.28),
                    CGPoint(x: size.width * 0.32, y: size.height * 0.68),
                    CGPoint(x: size.width * 0.68, y: size.height * 0.68)
                ]
                context.stroke(
                    Path(ellipseIn: CGRect(x: size.width * 0.18, y: size.height * 0.15, width: size.width * 0.64, height: size.height * 0.70)),
                    with: .color(pattern.color.opacity(0.35)),
                    style: StrokeStyle(lineWidth: 1.5, dash: [3, 3])
                )
            case .dispersed:
                points = [
                    CGPoint(x: size.width * 0.18, y: size.height * 0.28),
                    CGPoint(x: size.width * 0.72, y: size.height * 0.22),
                    CGPoint(x: size.width * 0.50, y: size.height * 0.76)
                ]
            }

            for point in points {
                let rect = CGRect(x: point.x - dot / 2, y: point.y - dot / 2, width: dot, height: dot)
                context.fill(Path(ellipseIn: rect), with: .color(pattern.color))
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

// MARK: - Planner cat

struct PlannerCat: View {
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            ZStack {
                // Ears
                Triangle()
                    .fill(Color(red: 0.95, green: 0.76, blue: 0.48))
                    .frame(width: size * 0.30, height: size * 0.30)
                    .rotationEffect(.degrees(-16))
                    .offset(x: -size * 0.22, y: -size * 0.30)
                Triangle()
                    .fill(Color(red: 0.95, green: 0.76, blue: 0.48))
                    .frame(width: size * 0.30, height: size * 0.30)
                    .rotationEffect(.degrees(16))
                    .offset(x: size * 0.22, y: -size * 0.30)

                // Face
                Circle()
                    .fill(Color(red: 0.96, green: 0.79, blue: 0.52))
                    .overlay {
                        VStack(spacing: size * 0.05) {
                            HStack(spacing: size * 0.18) {
                                Circle().frame(width: size * 0.055, height: size * 0.055)
                                Circle().frame(width: size * 0.055, height: size * 0.055)
                            }
                            Text("ω")
                                .font(.system(size: size * 0.18, weight: .medium, design: .rounded))
                        }
                        .foregroundStyle(Color(red: 0.15, green: 0.23, blue: 0.30))
                    }
                    .padding(size * 0.08)

                // Hard hat
                HardHat()
                    .fill(Color(red: 0.93, green: 0.70, blue: 0.24))
                    .frame(width: size * 0.60, height: size * 0.30)
                    .offset(y: -size * 0.30)
                    .overlay {
                        HardHat()
                            .stroke(Color(red: 0.55, green: 0.38, blue: 0.10), lineWidth: 1)
                            .frame(width: size * 0.60, height: size * 0.30)
                            .offset(y: -size * 0.30)
                    }

                // Collar badge
                Image(systemName: "leaf.fill")
                    .font(.system(size: size * 0.14, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(size * 0.06)
                    .background(Circle().fill(Color(red: 0.24, green: 0.50, blue: 0.34)))
                    .offset(x: size * 0.30, y: size * 0.30)
            }
        }
        .accessibilityHidden(true)
    }
}

private struct HardHat: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.10, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - rect.width * 0.10, y: rect.maxY),
            control: CGPoint(x: rect.midX, y: rect.minY - rect.height * 0.35)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
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

// MARK: - Map key swatches

struct TerrainSwatch: View {
    let terrain: SettlementTerrain
    var size: CGSize = CGSize(width: 30, height: 20)

    var body: some View {
        Canvas { context, canvasSize in
            let rect = CGRect(origin: .zero, size: canvasSize)
            let base: Color = switch terrain {
            case .grass: Color(red: 0.69, green: 0.82, blue: 0.55)
            case .river: Color(red: 0.45, green: 0.72, blue: 0.86)
            case .bridge: Color(red: 0.70, green: 0.61, blue: 0.46)
            case .road: Color(red: 0.44, green: 0.47, blue: 0.48)
            case .lane: Color(red: 0.74, green: 0.70, blue: 0.60)
            case .steep: Color(red: 0.73, green: 0.68, blue: 0.57)
            case .farmland: Color(red: 0.82, green: 0.77, blue: 0.52)
            case .woods: Color(red: 0.41, green: 0.65, blue: 0.40)
            }

            context.fill(Path(roundedRect: rect, cornerRadius: 4), with: .color(base))

            switch terrain {
            case .river:
                for y in [0.35, 0.65] {
                    var wave = Path()
                    wave.move(to: CGPoint(x: 0, y: canvasSize.height * y))
                    wave.addQuadCurve(
                        to: CGPoint(x: canvasSize.width, y: canvasSize.height * y),
                        control: CGPoint(x: canvasSize.width * 0.5, y: canvasSize.height * y - 4)
                    )
                    context.stroke(wave, with: .color(.white.opacity(0.6)), lineWidth: 1.2)
                }
            case .road, .lane:
                context.stroke(
                    Path(CGRect(x: 0, y: canvasSize.height * 0.5, width: canvasSize.width, height: 0)),
                    with: .color(.white.opacity(0.75)),
                    style: StrokeStyle(lineWidth: 1.2, dash: [3, 3])
                )
            case .farmland:
                for y in [0.3, 0.5, 0.7] {
                    context.stroke(
                        Path(CGRect(x: 0, y: canvasSize.height * y, width: canvasSize.width, height: 0)),
                        with: .color(Color(red: 0.48, green: 0.45, blue: 0.25).opacity(0.55)),
                        lineWidth: 1
                    )
                }
            case .steep:
                for x in [0.25, 0.5, 0.75] {
                    var line = Path()
                    line.move(to: CGPoint(x: canvasSize.width * x, y: 2))
                    line.addLine(to: CGPoint(x: canvasSize.width * (x - 0.15), y: canvasSize.height - 2))
                    context.stroke(line, with: .color(Color(red: 0.40, green: 0.36, blue: 0.30).opacity(0.55)), lineWidth: 1)
                }
            case .woods:
                context.fill(
                    Path(ellipseIn: CGRect(x: canvasSize.width * 0.35, y: canvasSize.height * 0.15, width: 10, height: 10)),
                    with: .color(Color(red: 0.20, green: 0.42, blue: 0.22))
                )
            default:
                break
            }
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .accessibilityHidden(true)
    }
}
