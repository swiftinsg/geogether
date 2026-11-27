import SwiftUI

// MARK: - Geometry

struct SettlementMapGeometry {
    let size: CGFloat
    let inset: CGFloat = 16

    var gridRect: CGRect {
        CGRect(x: inset, y: inset, width: size - inset * 2, height: size - inset * 2)
    }

    var cellSize: CGFloat {
        gridRect.width / CGFloat(SettlementMapData.size)
    }

    func cellRect(_ cell: SettlementCell) -> CGRect {
        CGRect(
            x: gridRect.minX + CGFloat(cell.column) * cellSize,
            y: gridRect.minY + CGFloat(cell.row) * cellSize,
            width: cellSize,
            height: cellSize
        )
    }

    func center(of cell: SettlementCell) -> CGPoint {
        let rect = cellRect(cell)
        return CGPoint(x: rect.midX, y: rect.midY)
    }

    func cell(at point: CGPoint) -> SettlementCell? {
        guard gridRect.contains(point), cellSize > 0 else { return nil }
        let column = Int((point.x - gridRect.minX) / cellSize)
        let row = Int((point.y - gridRect.minY) / cellSize)
        guard (0..<SettlementMapData.size).contains(column),
              (0..<SettlementMapData.size).contains(row) else { return nil }
        return SettlementCell(column: column, row: row)
    }

    func boundingRect(for cells: [SettlementCell]) -> CGRect {
        guard let first = cells.first else { return .zero }
        var rect = cellRect(first)
        for cell in cells.dropFirst() {
            rect = rect.union(cellRect(cell))
        }
        return rect
    }
}

// MARK: - Map

struct SettlementMapView: View {
    @ObservedObject var model: SettlementPlannerModel
    let onSiteTap: (SettlementSiteID) -> Void

    @EnvironmentObject private var touchGlobe: TouchGlobeState
    @State private var homeDragLocation: CGPoint?
    @State private var isDraggingHomes = false

    private var showsEvidenceOverlays: Bool {
        model.phase == .results || model.phase == .comparing || model.phase == .event || model.phase == .report
    }

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            let geo = SettlementMapGeometry(size: side)

            ZStack(alignment: .topLeading) {
                SettlementTerrainCanvas(geometry: geo)

                ForEach(SettlementMapData.sites) { site in
                    SiteZoneView(
                        site: site,
                        geometry: geo,
                        isHovered: model.hoveredSite == site.id,
                        isPlaced: model.placedSite == site.id,
                        isTested: model.tested[site.id] != nil,
                        pattern: model.tested[site.id]?.assessment.pattern,
                        action: { onSiteTap(site.id) }
                    )
                }

                ForEach(SettlementMapData.features) { feature in
                    SettlementFeatureView(feature: feature, cellSize: geo.cellSize)
                        .position(geo.center(of: feature.cell))

                    if feature.artwork != .home {
                        FeatureLabel(title: feature.title, cellSize: geo.cellSize)
                            .position(
                                x: geo.center(of: feature.cell).x,
                                y: geo.center(of: feature.cell).y + geo.cellSize * 0.50
                            )
                    }
                }

                if showsEvidenceOverlays {
                    FloodRiskOverlay(geometry: geo, isHighlighted: model.placedSite == .b)
                        .allowsHitTesting(false)
                }

                if let placedSiteID = model.placedSite {
                    let site = SettlementMapData.site(for: placedSiteID)

                    if showsEvidenceOverlays {
                        FarmlandOverlay(site: site, geometry: geo)
                            .allowsHitTesting(false)
                    }

                    HomeClusterOnMap(
                        site: site,
                        geometry: geo,
                        isDragging: isDraggingHomes,
                        isMovable: model.phase == .brief || model.phase == .placing || model.phase == .results,
                        onHover: { hovered in
                            model.hoveredSite = hovered
                        },
                        onDrop: { target in
                            finishDrag(target: target)
                        },
                        onDragStateChange: { dragging in
                            touchGlobe.isSuppressed = dragging
                        },
                        dragLocation: $homeDragLocation,
                        isDraggingBinding: $isDraggingHomes
                    )

                    if showsEvidenceOverlays {
                        PatternOverlay(site: site, geometry: geo)
                            .allowsHitTesting(false)
                    }
                } else if model.phase == .brief || model.phase == .placing {
                    HomeClusterStaging(
                        geometry: geo,
                        isDragging: isDraggingHomes,
                        onHover: { hovered in
                            model.hoveredSite = hovered
                        },
                        onDrop: { target in
                            finishDrag(target: target)
                        },
                        onDragStateChange: { dragging in
                            touchGlobe.isSuppressed = dragging
                        },
                        dragLocation: $homeDragLocation,
                        isDraggingBinding: $isDraggingHomes
                    )
                }

                if let homeDragLocation {
                    HomeClusterToken(size: geo.cellSize * 1.18, isValid: model.hoveredSite != nil)
                        .position(homeDragLocation)
                        .allowsHitTesting(false)
                        .transition(.scale(scale: 0.85).combined(with: .opacity))
                }
            }
            .frame(width: side, height: side)
            .coordinateSpace(name: "settlementMap")
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color(red: 0.73, green: 0.78, blue: 0.68), lineWidth: 1)
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Settlement map with three possible sites")
        }
        .aspectRatio(1, contentMode: .fit)
        .onDisappear {
            touchGlobe.isSuppressed = false
        }
    }

    private func finishDrag(target: SettlementSiteID?) {
        if let target {
            model.placeHomes(at: target)
        } else {
            model.showDropMessage()
        }
        model.hoveredSite = nil
        homeDragLocation = nil
        isDraggingHomes = false
        touchGlobe.isSuppressed = false
    }
}

// MARK: - Terrain

private struct SettlementTerrainCanvas: View {
    let geometry: SettlementMapGeometry

    private let grass = Color(red: 0.68, green: 0.82, blue: 0.55)
    private let grassDark = Color(red: 0.62, green: 0.78, blue: 0.50)
    private let farmland = Color(red: 0.84, green: 0.78, blue: 0.52)
    private let steep = Color(red: 0.73, green: 0.68, blue: 0.57)
    private let river = Color(red: 0.42, green: 0.70, blue: 0.86)
    private let riverDeep = Color(red: 0.28, green: 0.58, blue: 0.78)
    private let road = Color(red: 0.42, green: 0.45, blue: 0.46)
    private let lane = Color(red: 0.72, green: 0.67, blue: 0.56)
    private let stone = Color(red: 0.68, green: 0.60, blue: 0.48)
    private let cream = Color(red: 0.96, green: 0.95, blue: 0.89)
    private let ink = Color(red: 0.20, green: 0.24, blue: 0.20)

    var body: some View {
        Canvas { context, size in
            context.fill(
                Path(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 18),
                with: .color(cream)
            )

            context.drawLayer { layer in
                layer.clip(to: Path(geometry.gridRect))

                layer.fill(Path(geometry.gridRect), with: .color(grass))

                for row in 0..<SettlementMapData.size {
                    for column in 0..<SettlementMapData.size {
                        let cell = SettlementCell(column: column, row: row)
                        drawTerrainCell(cell, in: &layer)
                    }
                }

                drawRiver(in: &layer)
                drawRoads(in: &layer)
                drawTrees(in: &layer)
                drawGrid(in: &layer)
            }

            drawLabels(in: &context)
        }
    }

    private func drawTerrainCell(_ cell: SettlementCell, in context: inout GraphicsContext) {
        let rect = geometry.cellRect(cell)
        let terrain = SettlementMapData.terrain(at: cell)

        switch terrain {
        case .grass:
            let color = (cell.column + cell.row).isMultiple(of: 2) ? grass : grassDark
            context.fill(Path(rect), with: .color(color))
        case .farmland:
            context.fill(Path(rect), with: .color(farmland))
            for index in 0..<3 {
                let y = rect.minY + rect.height * (0.25 + CGFloat(index) * 0.25)
                context.stroke(
                    Path(CGRect(x: rect.minX + 2, y: y, width: rect.width - 4, height: 0.8)),
                    with: .color(Color(red: 0.52, green: 0.48, blue: 0.27).opacity(0.55)),
                    lineWidth: 1
                )
            }
        case .steep:
            context.fill(Path(rect), with: .color(steep))
            for index in 0..<3 {
                let inset = CGFloat(index) * rect.width * 0.14
                var contour = Path()
                contour.move(to: CGPoint(x: rect.minX + inset + 2, y: rect.maxY - 3))
                contour.addQuadCurve(
                    to: CGPoint(x: rect.maxX - 3, y: rect.minY + inset + 2),
                    control: CGPoint(x: rect.midX, y: rect.midY - 4)
                )
                context.stroke(
                    contour,
                    with: .color(Color(red: 0.40, green: 0.36, blue: 0.29).opacity(0.45)),
                    lineWidth: 1
                )
            }
        case .woods:
            context.fill(Path(rect), with: .color(grassDark))
        case .river:
            context.fill(Path(rect), with: .color(river))
        case .bridge:
            context.fill(Path(rect), with: .color(river))
        case .road:
            context.fill(Path(rect), with: .color(road))
        case .lane:
            context.fill(Path(rect), with: .color(lane))
        }
    }

    private func drawRiver(in context: inout GraphicsContext) {
        let columnCenter = geometry.center(of: SettlementCell(column: 6, row: 0)).x
        let width = geometry.cellSize * 0.74
        let rect = CGRect(
            x: columnCenter - width / 2,
            y: geometry.gridRect.minY,
            width: width,
            height: geometry.gridRect.height
        )

        context.fill(Path(roundedRect: rect, cornerRadius: width * 0.25), with: .color(river))

        for row in 0..<SettlementMapData.size {
            let y = geometry.center(of: SettlementCell(column: 6, row: row)).y
            var wave = Path()
            wave.move(to: CGPoint(x: rect.minX + 4, y: y - 2))
            wave.addQuadCurve(
                to: CGPoint(x: rect.maxX - 4, y: y - 2),
                control: CGPoint(x: rect.midX, y: y + 5)
            )
            context.stroke(wave, with: .color(.white.opacity(0.45)), lineWidth: 1.2)
        }

        context.stroke(
            Path(roundedRect: rect, cornerRadius: width * 0.25),
            with: .color(riverDeep.opacity(0.65)),
            lineWidth: 1.4
        )

        // Bridge at G5.
        let bridgeCell = SettlementCell(column: 6, row: 4)
        let bridgeCenter = geometry.center(of: bridgeCell)
        let bridgeRect = CGRect(
            x: bridgeCenter.x - geometry.cellSize * 0.48,
            y: bridgeCenter.y - geometry.cellSize * 0.28,
            width: geometry.cellSize * 0.96,
            height: geometry.cellSize * 0.56
        )
        context.fill(Path(roundedRect: bridgeRect, cornerRadius: 3), with: .color(stone))
        context.stroke(Path(roundedRect: bridgeRect, cornerRadius: 3), with: .color(ink.opacity(0.55)), lineWidth: 1.2)
        for index in 0..<5 {
            let x = bridgeRect.minX + bridgeRect.width * CGFloat(index) / 4
            context.stroke(
                Path(CGRect(x: x, y: bridgeRect.minY + 2, width: 0.8, height: bridgeRect.height - 4)),
                with: .color(ink.opacity(0.25)),
                lineWidth: 0.8
            )
        }
    }

    private func drawRoads(in context: inout GraphicsContext) {
        let roadCenterY = geometry.center(of: SettlementCell(column: 0, row: 4)).y
        let roadHeight = geometry.cellSize * 0.58
        let roadRect = CGRect(
            x: geometry.gridRect.minX,
            y: roadCenterY - roadHeight / 2,
            width: geometry.gridRect.width,
            height: roadHeight
        )

        context.fill(Path(roundedRect: roadRect, cornerRadius: 2), with: .color(road))
        context.stroke(
            Path(CGRect(x: roadRect.minX, y: roadRect.midY, width: roadRect.width, height: 0.8)),
            with: .color(.white.opacity(0.55)),
            style: StrokeStyle(lineWidth: 1.1, dash: [5, 5])
        )
        context.stroke(
            Path(roundedRect: roadRect, cornerRadius: 2),
            with: .color(ink.opacity(0.25)),
            lineWidth: 0.8
        )

        for column in [1, 4] {
            let laneCenterX = geometry.center(of: SettlementCell(column: column, row: 5)).x
            let laneWidth = geometry.cellSize * 0.38
            let laneRect = CGRect(
                x: laneCenterX - laneWidth / 2,
                y: geometry.center(of: SettlementCell(column: column, row: 5)).y - geometry.cellSize * 0.2,
                width: laneWidth,
                height: geometry.cellSize * 3.4
            )
            context.fill(Path(roundedRect: laneRect, cornerRadius: 2), with: .color(lane))
            context.stroke(
                Path(CGRect(x: laneRect.midX, y: laneRect.minY, width: 0.8, height: laneRect.height)),
                with: .color(.white.opacity(0.5)),
                style: StrokeStyle(lineWidth: 1, dash: [4, 4])
            )
            context.stroke(
                Path(roundedRect: laneRect, cornerRadius: 2),
                with: .color(ink.opacity(0.18)),
                lineWidth: 0.8
            )
        }
    }

    private func drawTrees(in context: inout GraphicsContext) {
        for row in 0..<SettlementMapData.size {
            for column in 0..<SettlementMapData.size {
                let cell = SettlementCell(column: column, row: row)
                guard SettlementMapData.terrain(at: cell) == .woods else { continue }
                let center = geometry.center(of: cell)
                let scale = geometry.cellSize

                for (offset, size) in [(CGPoint(x: -0.18, y: 0.10), 0.34), (CGPoint(x: 0.18, y: -0.08), 0.28)] {
                    let x = center.x + scale * offset.x
                    let y = center.y + scale * offset.y
                    context.fill(
                        Path(CGRect(x: x - scale * 0.02, y: y + scale * size * 0.25, width: scale * 0.04, height: scale * size * 0.45)),
                        with: .color(Color(red: 0.43, green: 0.31, blue: 0.20))
                    )
                    context.fill(
                        Path(ellipseIn: CGRect(
                            x: x - scale * size * 0.5,
                            y: y - scale * size * 0.45,
                            width: scale * size,
                            height: scale * size
                        )),
                        with: .color(Color(red: 0.22, green: 0.46, blue: 0.24))
                    )
                    context.fill(
                        Path(ellipseIn: CGRect(
                            x: x - scale * size * 0.32,
                            y: y - scale * size * 0.40,
                            width: scale * size * 0.64,
                            height: scale * size * 0.64
                        )),
                        with: .color(Color(red: 0.34, green: 0.58, blue: 0.33))
                    )
                }
            }
        }
    }

    private func drawGrid(in context: inout GraphicsContext) {
        for index in 0...SettlementMapData.size {
            let offset = CGFloat(index) * geometry.cellSize
            let x = geometry.gridRect.minX + offset
            let y = geometry.gridRect.minY + offset

            context.stroke(
                Path(CGRect(x: x, y: geometry.gridRect.minY, width: 0.6, height: geometry.gridRect.height)),
                with: .color(.white.opacity(0.28)),
                lineWidth: 0.6
            )
            context.stroke(
                Path(CGRect(x: geometry.gridRect.minX, y: y, width: geometry.gridRect.width, height: 0.6)),
                with: .color(.white.opacity(0.28)),
                lineWidth: 0.6
            )
        }
    }

    private func drawLabels(in context: inout GraphicsContext) {
        let labelColor = Color(red: 0.31, green: 0.38, blue: 0.31)
        let fontSize = max(7, geometry.cellSize * 0.18)

        for column in 0..<SettlementMapData.size {
            let x = geometry.gridRect.minX + (CGFloat(column) + 0.5) * geometry.cellSize
            context.draw(
                Text(SettlementMapData.columnLetters[column])
                    .font(.system(size: fontSize, weight: .bold, design: .rounded))
                    .foregroundColor(labelColor),
                at: CGPoint(x: x, y: geometry.gridRect.minY / 2 + 1)
            )
        }

        for row in 0..<SettlementMapData.size {
            let y = geometry.gridRect.minY + (CGFloat(row) + 0.5) * geometry.cellSize
            context.draw(
                Text("\(row + 1)")
                    .font(.system(size: fontSize, weight: .bold, design: .rounded))
                    .foregroundColor(labelColor),
                at: CGPoint(x: geometry.gridRect.minX / 2 + 1, y: y)
            )
        }
    }
}

// MARK: - Feature label

private struct FeatureLabel: View {
    let title: String
    let cellSize: CGFloat

    var body: some View {
        Text(title)
            .font(.system(size: max(6, cellSize * 0.155), weight: .semibold, design: .rounded))
            .foregroundStyle(Color(red: 0.22, green: 0.29, blue: 0.23))
            .padding(.horizontal, 3)
            .padding(.vertical, 1)
            .background(.white.opacity(0.82), in: Capsule())
            .fixedSize()
            .accessibilityHidden(true)
    }
}

// MARK: - Site zones

private struct SiteZoneView: View {
    let site: SettlementSite
    let geometry: SettlementMapGeometry
    let isHovered: Bool
    let isPlaced: Bool
    let isTested: Bool
    let pattern: SettlementPattern?
    let action: () -> Void

    private var topCell: SettlementCell {
        site.cells.min { lhs, rhs in
            if lhs.row == rhs.row { return lhs.column < rhs.column }
            return lhs.row < rhs.row
        } ?? site.cells[0]
    }

    var body: some View {
        ZStack {
            ForEach(site.cells) { cell in
                RoundedRectangle(cornerRadius: geometry.cellSize * 0.12, style: .continuous)
                    .fill(site.color.opacity(isHovered ? 0.22 : (isPlaced ? 0.04 : 0.09)))
                    .overlay {
                        RoundedRectangle(cornerRadius: geometry.cellSize * 0.12, style: .continuous)
                            .strokeBorder(
                                site.color.opacity(isHovered ? 0.9 : 0.55),
                                style: StrokeStyle(lineWidth: isHovered ? 2 : 1.4, dash: isPlaced ? [] : [4, 3])
                            )
                    }
                    .frame(width: geometry.cellSize * 0.92, height: geometry.cellSize * 0.92)
                    .position(geometry.center(of: cell))
                    .contentShape(RoundedRectangle(cornerRadius: geometry.cellSize * 0.12, style: .continuous))
                    .onTapGesture(perform: action)
                    .accessibilityLabel("\(site.id.title), \(site.subtitle)")
                    .accessibilityHint("Double tap to place the three new homes here")
                    .accessibilityAddTraits(.isButton)
            }

            VStack(spacing: 2) {
                HStack(spacing: 3) {
                    Text(site.id.title)
                        .font(.system(size: max(7, geometry.cellSize * 0.17), weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(site.color, in: Capsule())

                    if isTested {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: max(8, geometry.cellSize * 0.2), weight: .bold))
                            .foregroundStyle(site.color)
                            .background(Circle().fill(.white))
                    }
                }

                if let pattern {
                    Text(pattern.title)
                        .font(.system(size: max(6, geometry.cellSize * 0.14), weight: .bold, design: .rounded))
                        .foregroundStyle(pattern.color)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(.white.opacity(0.88), in: Capsule())
                }
            }
            .position(
                x: geometry.center(of: topCell).x,
                y: geometry.center(of: topCell).y - geometry.cellSize * 0.58
            )
        }
        .frame(width: geometry.size, height: geometry.size)
    }
}

// MARK: - Homes on the map

private struct HomeClusterOnMap: View {
    let site: SettlementSite
    let geometry: SettlementMapGeometry
    let isDragging: Bool
    let isMovable: Bool
    let onHover: (SettlementSiteID?) -> Void
    let onDrop: (SettlementSiteID?) -> Void
    let onDragStateChange: (Bool) -> Void
    @Binding var dragLocation: CGPoint?
    @Binding var isDraggingBinding: Bool

    private var clusterRect: CGRect {
        geometry.boundingRect(for: site.cells).insetBy(dx: -geometry.cellSize * 0.06, dy: -geometry.cellSize * 0.06)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 6, coordinateSpace: .named("settlementMap"))
            .onChanged { value in
                isDraggingBinding = true
                onDragStateChange(true)
                dragLocation = value.location
                let target = geometry.cell(at: value.location).flatMap { SettlementMapData.site(at: $0) }
                onHover(target?.id)
            }
            .onEnded { value in
                let target = geometry.cell(at: value.location).flatMap { SettlementMapData.site(at: $0) }
                onDragStateChange(false)
                onDrop(target?.id)
            }
    }

    var body: some View {
        ZStack {
            ForEach(Array(site.cells.enumerated()), id: \.offset) { index, cell in
                let center = geometry.center(of: cell)
                HomeArtwork(variant: index)
                    .frame(width: geometry.cellSize * 0.74, height: geometry.cellSize * 0.70)
                    .position(
                        x: center.x - clusterRect.minX,
                        y: center.y - clusterRect.minY
                    )
            }
        }
        .frame(width: clusterRect.width, height: clusterRect.height)
        .position(x: clusterRect.midX, y: clusterRect.midY)
        .opacity(isDragging ? 0.35 : 1)
        .contentShape(Rectangle())
        .gesture(dragGesture, including: isMovable ? .all : .none)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Three new homes at \(site.id.title)")
        .accessibilityHint("Drag to move the homes to another site")
    }
}

// MARK: - Staging token

private struct HomeClusterStaging: View {
    let geometry: SettlementMapGeometry
    let isDragging: Bool
    let onHover: (SettlementSiteID?) -> Void
    let onDrop: (SettlementSiteID?) -> Void
    let onDragStateChange: (Bool) -> Void
    @Binding var dragLocation: CGPoint?
    @Binding var isDraggingBinding: Bool

    private var stagingPoint: CGPoint {
        CGPoint(
            x: geometry.gridRect.midX,
            y: geometry.gridRect.maxY - geometry.cellSize * 0.52
        )
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 6, coordinateSpace: .named("settlementMap"))
            .onChanged { value in
                isDraggingBinding = true
                onDragStateChange(true)
                dragLocation = value.location
                let target = geometry.cell(at: value.location).flatMap { SettlementMapData.site(at: $0) }
                onHover(target?.id)
            }
            .onEnded { value in
                let target = geometry.cell(at: value.location).flatMap { SettlementMapData.site(at: $0) }
                onDragStateChange(false)
                onDrop(target?.id)
            }
    }

    var body: some View {
        ZStack {
            if !isDragging {
                VStack(spacing: 2) {
                    Text("3 NEW HOMES")
                        .font(.system(size: max(7, geometry.cellSize * 0.15), weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(red: 0.20, green: 0.48, blue: 0.34))
                    Text("Drag onto a site")
                        .font(.system(size: max(6, geometry.cellSize * 0.13), weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(red: 0.31, green: 0.38, blue: 0.31))
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(.white.opacity(0.92), in: Capsule())
                .position(
                    x: stagingPoint.x,
                    y: stagingPoint.y - geometry.cellSize * 0.92
                )
                .allowsHitTesting(false)
            }

            HomeClusterToken(size: geometry.cellSize * 1.02, isValid: true)
                .position(stagingPoint)
                .opacity(isDragging ? 0.25 : 1)
                .gesture(dragGesture)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Three new homes ready to place")
                .accessibilityHint("Drag the homes onto a dashed site")
        }
        .frame(width: geometry.size, height: geometry.size)
    }
}

// MARK: - Overlays

private struct PatternOverlay: View {
    let site: SettlementSite
    let geometry: SettlementMapGeometry

    var body: some View {
        Canvas { context, _ in
            let centers = site.cells
                .sorted { lhs, rhs in
                    if lhs.row == rhs.row { return lhs.column < rhs.column }
                    return lhs.row < rhs.row
                }
                .map { geometry.center(of: $0) }

            guard centers.count > 1 else { return }

            switch site.pattern {
            case .linear:
                var line = Path()
                line.move(to: centers[0])
                for center in centers.dropFirst() {
                    line.addLine(to: center)
                }
                context.stroke(
                    line,
                    with: .color(site.pattern.color.opacity(0.85)),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5, 4])
                )
            case .nucleated:
                let rect = geometry.boundingRect(for: site.cells).insetBy(dx: -geometry.cellSize * 0.18, dy: -geometry.cellSize * 0.18)
                context.stroke(
                    Path(ellipseIn: rect),
                    with: .color(site.pattern.color.opacity(0.8)),
                    style: StrokeStyle(lineWidth: 1.8, dash: [5, 4])
                )
            case .dispersed:
                for center in centers {
                    let radius = geometry.cellSize * 0.46
                    context.stroke(
                        Path(ellipseIn: CGRect(
                            x: center.x - radius,
                            y: center.y - radius,
                            width: radius * 2,
                            height: radius * 2
                        )),
                        with: .color(site.pattern.color.opacity(0.7)),
                        style: StrokeStyle(lineWidth: 1.4, dash: [4, 4])
                    )
                }
            }
        }
    }
}

private struct FloodRiskOverlay: View {
    let geometry: SettlementMapGeometry
    let isHighlighted: Bool

    var body: some View {
        Canvas { context, _ in
            context.drawLayer { layer in
                layer.clip(to: Path(geometry.gridRect))

                for row in 0..<SettlementMapData.size {
                    for column in [5, 7] {
                        let cell = SettlementCell(column: column, row: row)
                        guard SettlementMapData.terrain(at: cell) != .river else { continue }
                        let rect = geometry.cellRect(cell)
                        layer.drawLayer { cellLayer in
                            cellLayer.clip(to: Path(rect))

                            let opacity = isHighlighted ? 0.42 : 0.22
                            var offset = -rect.height
                            while offset < rect.width {
                                var line = Path()
                                line.move(to: CGPoint(x: rect.minX + offset, y: rect.maxY))
                                line.addLine(to: CGPoint(x: rect.minX + offset + rect.height, y: rect.minY))
                                cellLayer.stroke(
                                    line,
                                    with: .color(Color(red: 0.25, green: 0.55, blue: 0.78).opacity(opacity)),
                                    lineWidth: 1.2
                                )
                                offset += 6
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct FarmlandOverlay: View {
    let site: SettlementSite
    let geometry: SettlementMapGeometry

    private var farmlandCells: [SettlementCell] {
        site.cells.filter { SettlementMapData.terrain(at: $0) == .farmland }
    }

    var body: some View {
        Canvas { context, _ in
            for cell in farmlandCells {
                let rect = geometry.cellRect(cell).insetBy(dx: 3, dy: 3)
                context.stroke(
                    Path(roundedRect: rect, cornerRadius: 4),
                    with: .color(Color(red: 0.76, green: 0.47, blue: 0.18)),
                    style: StrokeStyle(lineWidth: 2, dash: [4, 3])
                )

                var cross = Path()
                cross.move(to: CGPoint(x: rect.minX + 5, y: rect.minY + 5))
                cross.addLine(to: CGPoint(x: rect.maxX - 5, y: rect.maxY - 5))
                cross.move(to: CGPoint(x: rect.maxX - 5, y: rect.minY + 5))
                cross.addLine(to: CGPoint(x: rect.minX + 5, y: rect.maxY - 5))
                context.stroke(
                    cross,
                    with: .color(Color(red: 0.76, green: 0.47, blue: 0.18).opacity(0.85)),
                    lineWidth: 1.8
                )
            }
        }
    }
}
