import SwiftUI

/// A vector city keeps buildings and their tap targets aligned at every zoom level.
struct CityMapArtwork: View {
    var body: some View {
        Canvas { context, size in
            context.scaleBy(x: size.width / 720, y: size.height / 1100)
            drawBlocks(in: context)
            drawStreets(in: context)
            drawNeighbourhood(in: context)
        }
    }

    private func drawBlocks(in context: GraphicsContext) {
        for x in [CGFloat(18), 278, 518] {
            for y in [CGFloat(34), 386, 746] {
                let width: CGFloat = x == 278 ? 164 : 184
                rounded(CGRect(x: x, y: y, width: width, height: 270), radius: 20, color: Color(red: 0.79, green: 0.86, blue: 0.72), in: context)
                rounded(CGRect(x: x + 8, y: y + 8, width: width - 16, height: 254), radius: 16, color: Color(red: 0.88, green: 0.91, blue: 0.81), in: context)
            }
        }
    }

    private func drawStreets(in context: GraphicsContext) {
        let roads = [
            CGRect(x: 216, y: 0, width: 48, height: 1100),
            CGRect(x: 456, y: 0, width: 48, height: 1100),
            CGRect(x: 0, y: 328, width: 720, height: 44),
            CGRect(x: 0, y: 688, width: 720, height: 44),
            CGRect(x: 0, y: 1050, width: 720, height: 44)
        ]
        for road in roads {
            rounded(road.insetBy(dx: -9, dy: -9), radius: 0, color: Color(red: 0.97, green: 0.95, blue: 0.87), in: context)
        }
        for road in roads {
            rounded(road, radius: 0, color: Color(red: 0.40, green: 0.47, blue: 0.48), in: context)
        }

        var lanes = Path()
        for x in [CGFloat(240), 480] {
            lanes.move(to: CGPoint(x: x, y: 0))
            lanes.addLine(to: CGPoint(x: x, y: 1100))
        }
        for y in [CGFloat(350), 710, 1072] {
            lanes.move(to: CGPoint(x: 0, y: y))
            lanes.addLine(to: CGPoint(x: 720, y: y))
        }
        context.stroke(lanes, with: .color(.white.opacity(0.65)), style: StrokeStyle(lineWidth: 2, dash: [12, 12]))

        for x in [CGFloat(240), 480] {
            for y in [CGFloat(350), 710, 1072] {
                rounded(CGRect(x: x - 24, y: y - 22, width: 48, height: 44), radius: 0, color: Color(red: 0.40, green: 0.47, blue: 0.48), in: context)
                for stripe in 0..<5 {
                    let offset = CGFloat(stripe) * 8
                    rounded(CGRect(x: x - 18 + offset, y: y - 38, width: 4, height: 12), radius: 1, color: .white.opacity(0.88), in: context)
                    rounded(CGRect(x: x - 18 + offset, y: y + 26, width: 4, height: 12), radius: 1, color: .white.opacity(0.88), in: context)
                    rounded(CGRect(x: x - 40, y: y - 18 + offset, width: 12, height: 4), radius: 1, color: .white.opacity(0.88), in: context)
                    rounded(CGRect(x: x + 28, y: y - 18 + offset, width: 12, height: 4), radius: 1, color: .white.opacity(0.88), in: context)
                }
            }
        }
        car(x: 222, y: 140, vertical: true, color: Color(red: 0.92, green: 0.70, blue: 0.36), in: context)
        car(x: 488, y: 575, vertical: true, color: .white, in: context)
        car(x: 80, y: 334, vertical: false, color: Color(red: 0.73, green: 0.82, blue: 0.93), in: context)
        car(x: 568, y: 714, vertical: false, color: Color(red: 0.86, green: 0.49, blue: 0.40), in: context)
    }

    private func drawNeighbourhood(in context: GraphicsContext) {
        // Civic building and its paved entrance.
        rounded(CGRect(x: 42, y: 76, width: 138, height: 148), radius: 12, color: Color(red: 0.80, green: 0.82, blue: 0.76), in: context)
        building(CGRect(x: 50, y: 78, width: 120, height: 96), roof: Color(red: 0.42, green: 0.65, blue: 0.73), floors: 2, in: context)
        rounded(CGRect(x: 91, y: 91, width: 38, height: 54), radius: 3, color: Color(red: 0.69, green: 0.85, blue: 0.88), in: context)
        tree(x: 35, y: 208, in: context)
        tree(x: 187, y: 210, in: context)

        // Apartment towers with roof terraces.
        for origin in [CGPoint(x: 288, y: 85), CGPoint(x: 369, y: 63), CGPoint(x: 322, y: 168)] {
            building(CGRect(x: origin.x, y: origin.y, width: 62, height: 72), roof: Color(red: 0.45, green: 0.64, blue: 0.59), floors: 4, in: context)
            rounded(CGRect(x: origin.x + 10, y: origin.y + 10, width: 42, height: 25), radius: 3, color: Color(red: 0.32, green: 0.47, blue: 0.52), in: context)
        }

        // Background shops make the map feel like a connected city.
        for y in [CGFloat(72), 158] {
            building(CGRect(x: 536, y: y, width: 62, height: 65), roof: Color(red: 0.77, green: 0.64, blue: 0.48), floors: 2, in: context)
            building(CGRect(x: 616, y: y + 8, width: 56, height: 62), roof: Color(red: 0.65, green: 0.70, blue: 0.67), floors: 2, in: context)
        }

        // A residential block with a courtyard.
        for y in [CGFloat(430), 524] {
            building(CGRect(x: 40, y: y, width: 65, height: 65), roof: Color(red: 0.68, green: 0.72, blue: 0.61), floors: 3, in: context)
            building(CGRect(x: 128, y: y, width: 55, height: 65), roof: Color(red: 0.71, green: 0.62, blue: 0.54), floors: 2, in: context)
        }
        tree(x: 112, y: 510, in: context)

        // Outdoor dining plaza.
        rounded(CGRect(x: 292, y: 414, width: 136, height: 184), radius: 16, color: Color(red: 0.88, green: 0.80, blue: 0.66), in: context)
        building(CGRect(x: 300, y: 416, width: 118, height: 55), roof: Color(red: 0.81, green: 0.48, blue: 0.32), floors: 1, in: context)
        for x in [CGFloat(319), 383] {
            for y in [CGFloat(512), 569] {
                umbrella(x: x, y: y, in: context)
            }
        }

        // School, red pitched roof, courtyard and playing court.
        building(CGRect(x: 539, y: 429, width: 140, height: 75), roof: Color(red: 0.74, green: 0.36, blue: 0.32), floors: 2, in: context)
        polygon([CGPoint(x: 535, y: 429), CGPoint(x: 609, y: 401), CGPoint(x: 683, y: 429)], color: Color(red: 0.85, green: 0.46, blue: 0.37), in: context)
        rounded(CGRect(x: 552, y: 542, width: 116, height: 60), radius: 4, color: Color(red: 0.56, green: 0.70, blue: 0.60), in: context)
        context.stroke(Path(CGRect(x: 559, y: 549, width: 102, height: 46)), with: .color(.white.opacity(0.8)), lineWidth: 2)
        context.stroke(Path(ellipseIn: CGRect(x: 596, y: 559, width: 28, height: 28)), with: .color(.white.opacity(0.8)), lineWidth: 2)

        // Playground with a loop path, climbing frame, slide and swings.
        rounded(CGRect(x: 37, y: 790, width: 150, height: 160), radius: 65, color: Color(red: 0.92, green: 0.83, blue: 0.64), in: context)
        rounded(CGRect(x: 49, y: 802, width: 126, height: 136), radius: 56, color: Color(red: 0.75, green: 0.82, blue: 0.58), in: context)
        rounded(CGRect(x: 72, y: 831, width: 49, height: 43), radius: 5, color: Color(red: 0.47, green: 0.65, blue: 0.69), in: context)
        rounded(CGRect(x: 89, y: 859, width: 21, height: 58), radius: 8, color: Color(red: 0.87, green: 0.48, blue: 0.36), in: context)
        for x in [CGFloat(139), 163] {
            rounded(CGRect(x: x, y: 833, width: 4, height: 52), radius: 2, color: Color(red: 0.47, green: 0.39, blue: 0.28), in: context)
        }
        rounded(CGRect(x: 133, y: 832, width: 40, height: 5), radius: 2, color: Color(red: 0.47, green: 0.39, blue: 0.28), in: context)

        // Central green with a fountain and footpaths.
        rounded(CGRect(x: 292, y: 771, width: 136, height: 228), radius: 62, color: Color(red: 0.66, green: 0.78, blue: 0.57), in: context)
        rounded(CGRect(x: 350, y: 772, width: 20, height: 227), radius: 8, color: Color(red: 0.94, green: 0.89, blue: 0.74), in: context)
        rounded(CGRect(x: 292, y: 861, width: 136, height: 20), radius: 8, color: Color(red: 0.94, green: 0.89, blue: 0.74), in: context)
        context.fill(Path(ellipseIn: CGRect(x: 327, y: 837, width: 66, height: 66)), with: .color(Color(red: 0.92, green: 0.92, blue: 0.80)))
        context.fill(Path(ellipseIn: CGRect(x: 336, y: 846, width: 48, height: 48)), with: .color(Color(red: 0.48, green: 0.74, blue: 0.80)))
        context.fill(Path(ellipseIn: CGRect(x: 351, y: 861, width: 18, height: 18)), with: .color(.white.opacity(0.75)))

        // Community garden with raised planting beds.
        rounded(CGRect(x: 540, y: 787, width: 140, height: 179), radius: 12, color: Color(red: 0.82, green: 0.76, blue: 0.59), in: context)
        for x in [CGFloat(552), 615] {
            for y in [CGFloat(801), 855, 909] {
                rounded(CGRect(x: x, y: y, width: 50, height: 40), radius: 5, color: Color(red: 0.51, green: 0.42, blue: 0.29), in: context)
                for plant in 0..<3 {
                    context.fill(Path(ellipseIn: CGRect(x: x + 5 + CGFloat(plant) * 13, y: y + 7, width: 14, height: 25)), with: .color(Color(red: 0.44, green: 0.64, blue: 0.35)))
                }
            }
        }

        for point in [
            CGPoint(x: 37, y: 52), CGPoint(x: 188, y: 52), CGPoint(x: 300, y: 44),
            CGPoint(x: 432, y: 257), CGPoint(x: 541, y: 280), CGPoint(x: 682, y: 280),
            CGPoint(x: 35, y: 638), CGPoint(x: 185, y: 637), CGPoint(x: 292, y: 636),
            CGPoint(x: 432, y: 636), CGPoint(x: 540, y: 637), CGPoint(x: 683, y: 637),
            CGPoint(x: 40, y: 776), CGPoint(x: 182, y: 978), CGPoint(x: 304, y: 798),
            CGPoint(x: 412, y: 965), CGPoint(x: 537, y: 989), CGPoint(x: 684, y: 778)
        ] {
            tree(x: point.x, y: point.y, in: context)
        }
    }

    private func building(_ rect: CGRect, roof: Color, floors: Int, in context: GraphicsContext) {
        let depth = CGFloat(floors) * 8
        rounded(rect.offsetBy(dx: 9, dy: depth + 5), radius: 5, color: .black.opacity(0.10), in: context)
        rounded(CGRect(x: rect.minX, y: rect.minY + depth, width: rect.width, height: rect.height), radius: 4, color: Color(red: 0.76, green: 0.76, blue: 0.66), in: context)
        rounded(rect, radius: 5, color: roof, in: context)
        context.stroke(Path(roundedRect: rect.insetBy(dx: 5, dy: 5), cornerRadius: 3), with: .color(.white.opacity(0.25)), lineWidth: 2)
        for row in 0..<floors {
            for column in stride(from: CGFloat(9), to: rect.width - 8, by: 17) {
                rounded(CGRect(x: rect.minX + column, y: rect.maxY + 3 + CGFloat(row) * 7, width: 8, height: 4), radius: 1, color: Color(red: 0.35, green: 0.49, blue: 0.50), in: context)
            }
        }
    }

    private func tree(x: CGFloat, y: CGFloat, in context: GraphicsContext) {
        context.fill(Path(ellipseIn: CGRect(x: x - 10, y: y - 8, width: 29, height: 29)), with: .color(.black.opacity(0.08)))
        rounded(CGRect(x: x - 2, y: y + 2, width: 4, height: 17), radius: 2, color: Color(red: 0.49, green: 0.42, blue: 0.28), in: context)
        context.fill(Path(ellipseIn: CGRect(x: x - 15, y: y - 19, width: 30, height: 32)), with: .color(Color(red: 0.34, green: 0.57, blue: 0.39)))
        context.fill(Path(ellipseIn: CGRect(x: x - 12, y: y - 18, width: 22, height: 23)), with: .color(Color(red: 0.49, green: 0.67, blue: 0.43)))
    }

    private func umbrella(x: CGFloat, y: CGFloat, in context: GraphicsContext) {
        for offset in [CGPoint(x: -16, y: -4), CGPoint(x: 10, y: -4), CGPoint(x: -4, y: 12)] {
            rounded(CGRect(x: x + offset.x, y: y + offset.y, width: 9, height: 9), radius: 3, color: Color(red: 0.60, green: 0.49, blue: 0.35), in: context)
        }
        context.fill(Path(ellipseIn: CGRect(x: x - 14, y: y - 16, width: 30, height: 30)), with: .color(.black.opacity(0.08)))
        context.fill(Path(ellipseIn: CGRect(x: x - 15, y: y - 21, width: 28, height: 28)), with: .color(Color(red: 0.98, green: 0.91, blue: 0.73)))
        polygon([CGPoint(x: x - 1, y: y - 7), CGPoint(x: x - 15, y: y - 7), CGPoint(x: x - 1, y: y - 21)], color: Color(red: 0.81, green: 0.56, blue: 0.36), in: context)
    }

    private func car(x: CGFloat, y: CGFloat, vertical: Bool, color: Color, in context: GraphicsContext) {
        let rect = CGRect(x: x, y: y, width: vertical ? 13 : 27, height: vertical ? 27 : 13)
        rounded(rect.offsetBy(dx: 2, dy: 2), radius: 4, color: .black.opacity(0.16), in: context)
        rounded(rect, radius: 4, color: color, in: context)
        rounded(rect.insetBy(dx: vertical ? 2 : 7, dy: vertical ? 7 : 2), radius: 2, color: Color(red: 0.32, green: 0.48, blue: 0.53), in: context)
    }

    private func rounded(_ rect: CGRect, radius: CGFloat, color: Color, in context: GraphicsContext) {
        context.fill(Path(roundedRect: rect, cornerRadius: radius), with: .color(color))
    }

    private func polygon(_ points: [CGPoint], color: Color, in context: GraphicsContext) {
        guard let first = points.first else { return }
        var path = Path()
        path.move(to: first)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        path.closeSubpath()
        context.fill(path, with: .color(color))
    }
}
