import SwiftUI

struct HousingMapScene: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geometry in
            let scale = geometry.size.width / 1000

            TimelineView(.animation(minimumInterval: 1.0 / 30, paused: reduceMotion)) { timeline in
                let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
                ZStack(alignment: .topLeading) {
                    HousingMapRoads(time: time, isMoving: !reduceMotion)

                    ForEach(HousingLocation.allCases) { location in
                        HousingPlotLink(location: location, time: time, scale: scale, isMoving: !reduceMotion)
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
    @ScaledMetric(relativeTo: .caption) private var labelHeight: CGFloat = 40

    var body: some View {
        let position = location.scenePosition(at: time, isMoving: isMoving)
        let phase = time * 1.2 + location.motionPhase
        let glow = isMoving ? 0.75 + sin(phase) * 0.25 : 0.85
        let angle = Angle.degrees(isMoving ? sin(phase) * 4 : 0)

        NavigationLink {
            HousingLocationDetailView(location: location)
        } label: {
            VStack(spacing: 12) {
                FloatingHousingPlot(location: location, glow: glow)
                    .frame(width: location.sceneSize.width * scale, height: location.sceneSize.height * scale)
                    .rotation3DEffect(angle, axis: (x: 1, y: 0.5, z: 0), perspective: 0.35)

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
            let crop = location.mapBounds
            let imageWidth = (geometry.size.width - inset * 2) / crop.width

            ZStack {
                shape
                    .fill(Color(red: 0.37, green: 0.53, blue: 0.38))
                    .offset(y: 4)
                    .shadow(color: Color(red: 0.15, green: 0.30, blue: 0.19).opacity(0.16), radius: 6, y: 9)

                shape
                    .fill(Color(red: 0.76, green: 0.87, blue: 0.68))

                // Display an independent window onto the original artwork.
                // The drawing stays unchanged while its six pieces move separately.
                Image("SustainableHousingMap")
                    .resizable()
                    .frame(width: imageWidth, height: imageWidth)
                    .offset(x: -crop.minX * imageWidth, y: -crop.minY * imageWidth)
                    .frame(
                        width: geometry.size.width - inset * 2,
                        height: geometry.size.height - inset * 2,
                        alignment: .topLeading
                    )
                    .clipped()
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: location == .school ? geometry.size.height * 0.6 : max(0, cornerRadius - inset),
                            bottomLeadingRadius: max(0, cornerRadius - inset),
                            bottomTrailingRadius: max(0, cornerRadius - inset),
                            topTrailingRadius: max(0, cornerRadius - inset)
                        )
                    )

                shape
                    .strokeBorder(Color(red: 1, green: 0.87, blue: 0.46).opacity(glow), lineWidth: 1.5)
                    .shadow(color: .yellow.opacity(glow * 0.6), radius: 5)
                    .shadow(color: .yellow.opacity(glow * 0.3), radius: 9)
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
                    let progress = (time * 0.12 + connection.from.motionPhase).truncatingRemainder(dividingBy: 1)
                    let point = connection.point(at: progress, start: start, control1: control1, control2: control2, end: end)
                    var light = context
                    light.addFilter(.shadow(color: .yellow.opacity(0.8), radius: 8))
                    light.fill(Path(ellipseIn: CGRect(x: point.x - 4, y: point.y - 4, width: 8, height: 8)), with: .color(Color(red: 1, green: 0.91, blue: 0.57)))
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
