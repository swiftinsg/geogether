import SwiftUI

struct HousingMapScene: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Namespace private var communityTransition

    var body: some View {
        GeometryReader { geometry in
            let scale = geometry.size.width / 1000

            TimelineView(.animation(minimumInterval: 1.0 / 30, paused: reduceMotion)) { timeline in
                let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
                ZStack(alignment: .topLeading) {
                    HousingMapRoads(time: time, isMoving: !reduceMotion)

                    ForEach(HousingLocation.allCases) { location in
                        HousingPlotLink(location: location, time: time, scale: scale, isMoving: !reduceMotion, transitionNamespace: communityTransition)
                    }
                }
            }
        }
        .aspectRatio(1000.0 / 1180, contentMode: .fit)
        .environment(\.layoutDirection, .leftToRight)
    }
}

private struct HousingPlotLink: View {
    let location: HousingLocation
    let time: TimeInterval
    let scale: CGFloat
    let isMoving: Bool
    let transitionNamespace: Namespace.ID
    @ScaledMetric(relativeTo: .caption) private var labelHeight: CGFloat = 40

    var body: some View {
        let position = location.scenePosition(at: time, isMoving: isMoving)
        let phase = time * 1.2 + location.motionPhase
        let glow = isMoving ? 0.75 + sin(phase) * 0.25 : 0.85
        let angle = Angle.degrees(isMoving && location != .community ? sin(phase) * 4 : 0)

        NavigationLink {
            HousingLocationDetailView(location: location)
                .navigationTransition(.zoom(sourceID: location.id, in: transitionNamespace))
        } label: {
            VStack(spacing: 12) {
                FloatingHousingPlot(location: location, glow: glow)
                    .frame(width: location.sceneSize.width * scale, height: location.sceneSize.height * scale)
                    .rotation3DEffect(angle, axis: (x: 1, y: 0.5, z: 0), perspective: 0.35)
                    .matchedTransitionSource(id: location.id, in: transitionNamespace)

                Text(location.title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(red: 0.17, green: 0.30, blue: 0.23))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 10)
                    .frame(height: labelHeight)
                    .frame(maxWidth: .infinity)
                    .background(.white.opacity(0.96), in: RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(location.color.opacity(0.12), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.04), radius: 3, y: 2)
            }
            .frame(width: max(110, location.sceneSize.width * scale))
            .contentShape(Rectangle())
        }
        .buttonStyle(HousingPlotButtonStyle())
        // Keep the artwork centred on its road connection, with the name below it.
        .position(x: position.x * scale, y: position.y * scale + (labelHeight + 12) / 2)
        .accessibilityLabel(Text(location.title))
        .accessibilityHint("Opens this place")
    }
}

private struct FloatingHousingPlot: View {
    let location: HousingLocation
    let glow: Double

    var body: some View {
        GeometryReader { geometry in
            let cornerRadius = min(geometry.size.width, geometry.size.height) * 0.22
            let shape = RoundedRectangle(cornerRadius: cornerRadius)
            let inset: CGFloat = 3

            ZStack {
                shape
                    .fill(Color(red: 0.37, green: 0.53, blue: 0.38))
                    .offset(y: 4)
                    .shadow(color: Color(red: 0.15, green: 0.30, blue: 0.19).opacity(0.16), radius: 6, y: 9)

                shape
                    .fill(Color(red: 0.76, green: 0.87, blue: 0.68))

                HousingArtwork(location: location)
                .frame(width: geometry.size.width - inset * 2, height: geometry.size.height - inset * 2)
                .padding(inset)
                .clipShape(RoundedRectangle(cornerRadius: max(0, cornerRadius - inset)))

                shape
                    .strokeBorder(Color(red: 1, green: 0.87, blue: 0.46).opacity(glow), lineWidth: 1.5)
                    .shadow(color: .yellow.opacity(glow * 0.6), radius: 5)
                    .shadow(color: .yellow.opacity(glow * 0.3), radius: 9)
            }
        }
    }
}

private struct NeighbourhoodSchoolArtwork: View {
    var body: some View {
        Canvas { context, size in
            context.scaleBy(x: size.width / 300, y: size.height / 190)
            context.fill(Path(CGRect(x: 0, y: 0, width: 300, height: 190)), with: .color(Color(red: 0.68, green: 0.85, blue: 0.84)))
            context.fill(Path(ellipseIn: CGRect(x: 225, y: 15, width: 42, height: 42)), with: .color(Color(red: 0.98, green: 0.84, blue: 0.48)))
            context.fill(Path(CGRect(x: 0, y: 137, width: 300, height: 53)), with: .color(Color(red: 0.60, green: 0.72, blue: 0.47)))
            context.fill(Path(CGRect(x: 28, y: 149, width: 245, height: 25)), with: .color(Color(red: 0.85, green: 0.78, blue: 0.60)))
            context.fill(Path(roundedRect: CGRect(x: 47, y: 70, width: 208, height: 83), cornerRadius: 7), with: .color(Color(red: 0.79, green: 0.38, blue: 0.29)))
            context.fill(Path(roundedRect: CGRect(x: 55, y: 78, width: 192, height: 70), cornerRadius: 5), with: .color(Color(red: 0.95, green: 0.79, blue: 0.58)))
            context.fill(Path(roundedRect: CGRect(x: 55, y: 119, width: 192, height: 29), cornerRadius: 3), with: .color(Color(red: 0.83, green: 0.43, blue: 0.31)))
            var roof = Path()
            roof.move(to: CGPoint(x: 32, y: 76))
            roof.addLine(to: CGPoint(x: 150, y: 25))
            roof.addLine(to: CGPoint(x: 269, y: 76))
            roof.closeSubpath()
            context.fill(roof, with: .color(Color(red: 0.69, green: 0.27, blue: 0.25)))
            context.fill(Path(roundedRect: CGRect(x: 111, y: 47, width: 78, height: 27), cornerRadius: 7), with: .color(Color(red: 0.97, green: 0.83, blue: 0.61)))
            context.draw(Text("SCHOOL").font(.system(size: 13, weight: .heavy, design: .rounded)).foregroundColor(Color(red: 0.58, green: 0.34, blue: 0.25)), at: CGPoint(x: 150, y: 61))
            for x in [72.0, 111.0, 190.0, 229.0] {
                context.fill(Path(roundedRect: CGRect(x: x, y: 87, width: 22, height: 25), cornerRadius: 4), with: .color(Color(red: 0.54, green: 0.75, blue: 0.77)))
                context.stroke(Path(CGRect(x: x + 11, y: 87, width: 1, height: 25)), with: .color(.white.opacity(0.85)), lineWidth: 2)
                context.stroke(Path(CGRect(x: x, y: 99, width: 22, height: 1)), with: .color(.white.opacity(0.85)), lineWidth: 2)
            }
            context.fill(Path(roundedRect: CGRect(x: 137, y: 112, width: 26, height: 36), cornerRadius: 4), with: .color(Color(red: 0.45, green: 0.62, blue: 0.68)))
            context.fill(Path(roundedRect: CGRect(x: 21, y: 151, width: 258, height: 7), cornerRadius: 3), with: .color(Color(red: 0.96, green: 0.88, blue: 0.68)))
            for x in [28.0, 272.0] {
                context.fill(Path(ellipseIn: CGRect(x: x - 15, y: 107, width: 30, height: 32)), with: .color(Color(red: 0.30, green: 0.55, blue: 0.39)))
                context.fill(Path(ellipseIn: CGRect(x: x - 10, y: 102, width: 22, height: 25)), with: .color(Color(red: 0.45, green: 0.68, blue: 0.45)))
            }
        }
    }
}

private struct HawkerCentreArtwork: View {
    var body: some View {
        Canvas { context, size in
            context.scaleBy(x: size.width / 300, y: size.height / 190)
            context.fill(Path(CGRect(x: 0, y: 0, width: 300, height: 190)), with: .color(Color(red: 0.72, green: 0.84, blue: 0.81)))
            context.fill(Path(CGRect(x: 0, y: 142, width: 300, height: 48)), with: .color(Color(red: 0.48, green: 0.65, blue: 0.43)))
            // Low, open-air food centre with a broad metal roof.
            context.fill(Path(CGRect(x: 26, y: 58, width: 248, height: 94)), with: .color(Color(red: 0.86, green: 0.79, blue: 0.65)))
            context.fill(Path(CGRect(x: 20, y: 48, width: 260, height: 14)), with: .color(Color(red: 0.48, green: 0.56, blue: 0.53)))
            context.fill(Path(CGRect(x: 34, y: 63, width: 232, height: 8)), with: .color(Color(red: 0.78, green: 0.43, blue: 0.31)))
            // Open stalls, signs, counters and service windows.
            for (index, x) in [CGFloat(39), 96, 153, 210].enumerated() {
                context.fill(Path(CGRect(x: x, y: 76, width: 49, height: 57)), with: .color(Color(red: 0.96, green: 0.89, blue: 0.73)))
                context.fill(Path(CGRect(x: x, y: 76, width: 49, height: 13)), with: .color([Color(red: 0.77, green: 0.40, blue: 0.30), Color(red: 0.34, green: 0.57, blue: 0.54), Color(red: 0.82, green: 0.60, blue: 0.31), Color(red: 0.40, green: 0.53, blue: 0.65)][index]))
                context.fill(Path(CGRect(x: x + 5, y: 95, width: 39, height: 20)), with: .color(Color(red: 0.65, green: 0.75, blue: 0.72)))
                context.fill(Path(CGRect(x: x - 2, y: 118, width: 53, height: 7)), with: .color(Color(red: 0.63, green: 0.42, blue: 0.29)))
                context.fill(Path(CGRect(x: x + 3, y: 125, width: 4, height: 8)), with: .color(Color(red: 0.50, green: 0.43, blue: 0.34)))
                context.fill(Path(CGRect(x: x + 42, y: 125, width: 4, height: 8)), with: .color(Color(red: 0.50, green: 0.43, blue: 0.34)))
            }
            // Shared dining tables, stools and a tiled walkway.
            context.fill(Path(CGRect(x: 18, y: 151, width: 264, height: 6)), with: .color(Color(red: 0.88, green: 0.80, blue: 0.65)))
            for x in [CGFloat(69), 150, 231] {
                context.fill(Path(roundedRect: CGRect(x: x, y: 141, width: 30, height: 4), cornerRadius: 2), with: .color(Color(red: 0.57, green: 0.39, blue: 0.28)))
                for seatX in [x + 3, x + 23] {
                    context.fill(Path(ellipseIn: CGRect(x: seatX, y: 147, width: 7, height: 6)), with: .color(Color(red: 0.77, green: 0.51, blue: 0.35)))
                }
            }
            context.fill(Path(ellipseIn: CGRect(x: 12, y: 122, width: 22, height: 31)), with: .color(Color(red: 0.32, green: 0.56, blue: 0.39)))
            context.fill(Path(ellipseIn: CGRect(x: 267, y: 118, width: 25, height: 35)), with: .color(Color(red: 0.34, green: 0.58, blue: 0.40)))
        }
    }
}

private struct PublicHousingArtwork: View {
    var body: some View {
        Canvas { context, size in
            context.scaleBy(x: size.width / 190, y: size.height / 190)
            context.fill(Path(CGRect(x: 0, y: 0, width: 190, height: 190)), with: .color(Color(red: 0.73, green: 0.84, blue: 0.79)))
            context.fill(Path(CGRect(x: 0, y: 142, width: 190, height: 48)), with: .color(Color(red: 0.46, green: 0.65, blue: 0.43)))
            // A recognizable Singapore public housing block, with sheltered ground floor.
            context.fill(Path(CGRect(x: 28, y: 34, width: 139, height: 117)), with: .color(Color(red: 0.78, green: 0.73, blue: 0.62)))
            context.fill(Path(CGRect(x: 23, y: 28, width: 149, height: 11)), with: .color(Color(red: 0.57, green: 0.62, blue: 0.57)))
            context.fill(Path(CGRect(x: 28, y: 134, width: 139, height: 17)), with: .color(Color(red: 0.53, green: 0.59, blue: 0.55)))
            for row in 0..<5 {
                for column in 0..<5 {
                    let x = CGFloat(37 + column * 25)
                    let y = CGFloat(47 + row * 17)
                    context.fill(Path(CGRect(x: x, y: y, width: 17, height: 10)), with: .color(Color(red: 0.44, green: 0.67, blue: 0.70)))
                    context.stroke(Path(CGRect(x: x, y: y + 7, width: 17, height: 2)), with: .color(Color(red: 0.89, green: 0.85, blue: 0.74)), lineWidth: 1)
                }
            }
            // Void deck openings, lift lobby, and block number.
            for x in [CGFloat(44), 83, 122] {
                context.fill(Path(roundedRect: CGRect(x: x, y: 137, width: 23, height: 14), cornerRadius: 5), with: .color(Color(red: 0.36, green: 0.46, blue: 0.43)))
            }
            context.fill(Path(CGRect(x: 88, y: 121, width: 17, height: 30)), with: .color(Color(red: 0.84, green: 0.78, blue: 0.64)))
            context.fill(Path(ellipseIn: CGRect(x: 11, y: 135, width: 24, height: 26)), with: .color(Color(red: 0.29, green: 0.54, blue: 0.37)))
            context.fill(Path(ellipseIn: CGRect(x: 151, y: 133, width: 27, height: 29)), with: .color(Color(red: 0.31, green: 0.57, blue: 0.39)))
            context.fill(Path(CGRect(x: 0, y: 164, width: 190, height: 26)), with: .color(Color(red: 0.85, green: 0.78, blue: 0.64)))
        }
    }
}

private struct NeighbourhoodPlaygroundArtwork: View {
    var body: some View {
        Canvas { context, size in
            context.scaleBy(x: size.width / 190, y: size.height / 160)
            context.fill(Path(CGRect(x: 0, y: 0, width: 190, height: 160)), with: .color(Color(red: 0.72, green: 0.83, blue: 0.66)))
            context.fill(Path(roundedRect: CGRect(x: 10, y: 10, width: 170, height: 140), cornerRadius: 30), with: .color(Color(red: 0.89, green: 0.78, blue: 0.60)))
            context.fill(Path(roundedRect: CGRect(x: 16, y: 16, width: 158, height: 128), cornerRadius: 26), with: .color(Color(red: 0.80, green: 0.84, blue: 0.67)))
            // Rubber play surfacing and stepping pads.
            context.fill(Path(roundedRect: CGRect(x: 25, y: 28, width: 108, height: 99), cornerRadius: 22), with: .color(Color(red: 0.78, green: 0.73, blue: 0.64)))
            for (x, y) in [(33.0, 112.0), (58.0, 129.0), (91.0, 119.0), (126.0, 132.0)] {
                context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 15, height: 7)), with: .color(Color(red: 0.91, green: 0.85, blue: 0.71)))
            }
            // Raised play platform with safety rails and a small roof.
            context.fill(Path(roundedRect: CGRect(x: 48, y: 65, width: 51, height: 7), cornerRadius: 3), with: .color(Color(red: 0.39, green: 0.56, blue: 0.57)))
            for x in [52.0, 92.0] {
                context.fill(Path(roundedRect: CGRect(x: x, y: 36, width: 6, height: 32), cornerRadius: 2), with: .color(Color(red: 0.42, green: 0.54, blue: 0.51)))
            }
            var roof = Path()
            roof.move(to: CGPoint(x: 43, y: 39))
            roof.addLine(to: CGPoint(x: 75, y: 22))
            roof.addLine(to: CGPoint(x: 106, y: 39))
            roof.closeSubpath()
            context.fill(roof, with: .color(Color(red: 0.88, green: 0.54, blue: 0.37)))
            var slide = Path()
            slide.move(to: CGPoint(x: 100, y: 68))
            slide.addCurve(to: CGPoint(x: 125, y: 101), control1: CGPoint(x: 117, y: 72), control2: CGPoint(x: 112, y: 96))
            slide.addLine(to: CGPoint(x: 136, y: 101))
            context.stroke(slide, with: .color(Color(red: 0.78, green: 0.42, blue: 0.35)), style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round))
            // A-frame swings, crossbar, chains and two seats.
            var frame = Path()
            frame.move(to: CGPoint(x: 143, y: 34))
            frame.addLine(to: CGPoint(x: 160, y: 64))
            frame.move(to: CGPoint(x: 177, y: 34))
            frame.addLine(to: CGPoint(x: 160, y: 64))
            frame.move(to: CGPoint(x: 143, y: 34))
            frame.addLine(to: CGPoint(x: 177, y: 34))
            context.stroke(frame, with: .color(Color(red: 0.39, green: 0.37, blue: 0.32)), style: StrokeStyle(lineWidth: 3, lineCap: .round))
            for x in [150.0, 169.0] {
                context.stroke(Path(CGRect(x: x, y: 37, width: 1, height: 35)), with: .color(Color(red: 0.42, green: 0.40, blue: 0.35)), lineWidth: 1.5)
                context.fill(Path(roundedRect: CGRect(x: x - 4, y: 71, width: 9, height: 4), cornerRadius: 2), with: .color(Color(red: 0.45, green: 0.60, blue: 0.65)))
            }
            // A shade tree softens the edge of the play area.
            context.fill(Path(CGRect(x: 20, y: 86, width: 4, height: 28)), with: .color(Color(red: 0.48, green: 0.39, blue: 0.28)))
            context.fill(Path(ellipseIn: CGRect(x: 8, y: 67, width: 29, height: 29)), with: .color(Color(red: 0.35, green: 0.59, blue: 0.39)))
        }
    }
}

private struct NeighbourhoodParkArtwork: View {
    var body: some View {
        Canvas { context, size in
            context.scaleBy(x: size.width / 190, y: size.height / 190)
            context.fill(Path(CGRect(x: 0, y: 0, width: 190, height: 190)), with: .color(Color(red: 0.63, green: 0.79, blue: 0.56)))
            context.fill(Path(roundedRect: CGRect(x: 15, y: 15, width: 160, height: 160), cornerRadius: 34), with: .color(Color(red: 0.50, green: 0.70, blue: 0.46)))
            var path = Path()
            path.move(to: CGPoint(x: 7, y: 103))
            path.addCurve(to: CGPoint(x: 178, y: 83), control1: CGPoint(x: 57, y: 38), control2: CGPoint(x: 121, y: 159))
            context.stroke(path, with: .color(Color(red: 0.94, green: 0.86, blue: 0.69)), style: StrokeStyle(lineWidth: 18, lineCap: .round))
            context.stroke(path, with: .color(Color(red: 0.98, green: 0.93, blue: 0.80)), style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [5, 7]))
            context.fill(Path(ellipseIn: CGRect(x: 72, y: 69, width: 47, height: 47)), with: .color(Color(red: 0.87, green: 0.84, blue: 0.68)))
            context.fill(Path(ellipseIn: CGRect(x: 78, y: 75, width: 35, height: 35)), with: .color(Color(red: 0.41, green: 0.72, blue: 0.78)))
            for (x, y) in [(38.0, 45.0), (147.0, 47.0), (43.0, 148.0), (150.0, 139.0)] {
                context.fill(Path(roundedRect: CGRect(x: x - 3, y: y + 10, width: 6, height: 13), cornerRadius: 3), with: .color(Color(red: 0.48, green: 0.38, blue: 0.27)))
                context.fill(Path(ellipseIn: CGRect(x: x - 16, y: y - 14, width: 32, height: 32)), with: .color(Color(red: 0.28, green: 0.52, blue: 0.37)))
                context.fill(Path(ellipseIn: CGRect(x: x - 10, y: y - 12, width: 23, height: 22)), with: .color(Color(red: 0.43, green: 0.67, blue: 0.42)))
            }
            for x in [60.0, 128.0] {
                context.fill(Path(ellipseIn: CGRect(x: x, y: 25, width: 7, height: 7)), with: .color(Color(red: 0.96, green: 0.75, blue: 0.55)))
                context.fill(Path(ellipseIn: CGRect(x: x + 9, y: 29, width: 6, height: 6)), with: .color(Color(red: 0.94, green: 0.90, blue: 0.67)))
            }
        }
    }
}

private struct HousingPlotButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.05 : 1)
            .brightness(configuration.isPressed ? 0.06 : 0)
    }
}

private struct HousingMapRoads: View {
    let time: TimeInterval
    let isMoving: Bool

    private let connections: [HousingMapConnection] = [
        HousingMapConnection(from: .community, to: .homes),
        HousingMapConnection(from: .homes, to: .dining),
        HousingMapConnection(from: .homes, to: .school),
        HousingMapConnection(from: .homes, to: .playground),
        HousingMapConnection(from: .playground, to: .garden),
        HousingMapConnection(from: .school, to: .garden)
    ]

    var body: some View {
        Canvas { context, size in
            context.scaleBy(x: size.width / 1000, y: size.height / 1180)

            for connection in connections {
                let start = connection.from.scenePosition(at: time, isMoving: isMoving)
                let end = connection.to.scenePosition(at: time, isMoving: isMoving)
                let control1 = CGPoint(x: start.x + (end.x - start.x) * 0.55, y: start.y)
                let control2 = CGPoint(x: end.x - (end.x - start.x) * 0.35, y: end.y)
                var path = Path()
                path.move(to: start)
                path.addCurve(to: end, control1: control1, control2: control2)

                context.stroke(path, with: .color(Color(red: 0.49, green: 0.60, blue: 0.47)), style: StrokeStyle(lineWidth: 35, lineCap: .round))
                context.stroke(path, with: .color(Color(red: 0.74, green: 0.76, blue: 0.71)), style: StrokeStyle(lineWidth: 27, lineCap: .round))
                context.stroke(path, with: .color(.white.opacity(0.75)), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [8, 12]))

                if isMoving {
                    for carIndex in 0..<2 {
                        let progress = (time * 0.38 + connection.from.motionPhase * 0.17 + Double(carIndex) * 0.5)
                            .truncatingRemainder(dividingBy: 1)
                        let point = connection.point(at: progress, start: start, control1: control1, control2: control2, end: end)
                        let nextPoint = connection.point(at: min(progress + 0.01, 1), start: start, control1: control1, control2: control2, end: end)
                        let angle = atan2(nextPoint.y - point.y, nextPoint.x - point.x)
                        var car = context
                        car.translateBy(x: point.x, y: point.y)
                        car.rotate(by: .radians(angle))
                        let body = Path(roundedRect: CGRect(x: -13, y: -7, width: 26, height: 14), cornerRadius: 5)
                        car.fill(body.offsetBy(dx: 1, dy: 2), with: .color(.black.opacity(0.18)))
                        let colors: [Color] = [
                            Color(red: 0.93, green: 0.66, blue: 0.35),
                            Color(red: 0.40, green: 0.67, blue: 0.73),
                            Color(red: 0.84, green: 0.43, blue: 0.36),
                            Color(red: 0.95, green: 0.91, blue: 0.76)
                        ]
                        let colorIndex = (Int(connection.from.motionPhase) + carIndex) % colors.count
                        car.fill(body, with: .color(colors[colorIndex]))
                        car.fill(Path(roundedRect: CGRect(x: -6, y: -5, width: 12, height: 10), cornerRadius: 3), with: .color(Color(red: 0.73, green: 0.85, blue: 0.83)))
                        car.fill(Path(roundedRect: CGRect(x: 9, y: -4, width: 3, height: 3), cornerRadius: 1), with: .color(Color(red: 1, green: 0.92, blue: 0.68)))
                    }
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct HousingMapConnection {
    let from: HousingLocation
    let to: HousingLocation

    func point(at t: Double, start: CGPoint, control1: CGPoint, control2: CGPoint, end: CGPoint) -> CGPoint {
        let u = 1 - t
        return CGPoint(
            x: u * u * u * start.x + 3 * u * u * t * control1.x + 3 * u * t * t * control2.x + t * t * t * end.x,
            y: u * u * u * start.y + 3 * u * u * t * control1.y + 3 * u * t * t * control2.y + t * t * t * end.y
        )
    }
}

extension HousingLocation {
    var sceneSize: CGSize {
        let width: CGFloat = switch self {
        case .community: 290
        case .homes: 260
        case .dining: 290
        case .school: 300
        case .playground: 225
        case .garden: 190
        }
        return CGSize(width: width, height: width * mapBounds.height / mapBounds.width)
    }

    var motionPhase: Double {
        switch self {
        case .community: 0
        case .homes: 1
        case .dining: 2
        case .school: 3
        case .playground: 4
        case .garden: 5
        }
    }

    func scenePosition(at time: TimeInterval, isMoving: Bool) -> CGPoint {
        let center: CGPoint = switch self {
        case .community: CGPoint(x: 170, y: 285)
        case .homes: CGPoint(x: 470, y: 495)
        case .dining: CGPoint(x: 520, y: 130)
        case .school: CGPoint(x: 840, y: 355)
        case .playground: CGPoint(x: 260, y: 870)
        case .garden: CGPoint(x: 750, y: 870)
        }
        guard isMoving else { return center }
        let phase = time * 1.2 + motionPhase
        return CGPoint(x: center.x + cos(phase * 0.7) * 3, y: center.y + sin(phase) * 9)
    }
}

#Preview {
    NavigationStack {
        SustainableHousingView()
    }
}
