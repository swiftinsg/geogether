import SwiftUI

// MARK: - Patterns

enum SettlementPattern: String, CaseIterable, Identifiable {
    case linear
    case nucleated
    case dispersed

    var id: String { rawValue }

    var title: String {
        switch self {
        case .linear: "Linear"
        case .nucleated: "Nucleated"
        case .dispersed: "Dispersed"
        }
    }

    var definition: String {
        switch self {
        case .linear:
            "Homes follow one line, usually a road, river or valley."
        case .nucleated:
            "Homes cluster around a central place such as a school, market or crossroads."
        case .dispersed:
            "Homes are spread out with gaps between them."
        }
    }

    var shortHint: String {
        switch self {
        case .linear: "A row along a route"
        case .nucleated: "A cluster around a centre"
        case .dispersed: "Scattered with gaps"
        }
    }

    var color: Color {
        switch self {
        case .linear: Color(red: 0.78, green: 0.47, blue: 0.20)
        case .nucleated: Color(red: 0.18, green: 0.43, blue: 0.72)
        case .dispersed: Color(red: 0.35, green: 0.54, blue: 0.27)
        }
    }
}

// MARK: - Risk

enum SettlementRisk: String, CaseIterable {
    case low
    case moderate
    case high

    var title: String {
        switch self {
        case .low: "Low"
        case .moderate: "Moderate"
        case .high: "High"
        }
    }

    var symbol: String {
        switch self {
        case .low: "checkmark.shield.fill"
        case .moderate: "exclamationmark.triangle.fill"
        case .high: "exclamationmark.octagon.fill"
        }
    }

    var color: Color {
        switch self {
        case .low: Color(red: 0.23, green: 0.55, blue: 0.35)
        case .moderate: Color(red: 0.78, green: 0.53, blue: 0.16)
        case .high: Color(red: 0.72, green: 0.25, blue: 0.22)
        }
    }
}

// MARK: - Map cells

struct SettlementCell: Hashable, Identifiable {
    let column: Int
    let row: Int

    var id: String { label }

    var label: String {
        "\(SettlementMapData.columnLetters[column])\(row + 1)"
    }
}

enum SettlementTerrain: String {
    case grass
    case river
    case bridge
    case road
    case lane
    case steep
    case farmland
    case woods
}

// MARK: - Sites

enum SettlementSiteID: String, CaseIterable, Identifiable {
    case a
    case b
    case c

    var id: String { rawValue }

    var letter: String {
        switch self {
        case .a: "A"
        case .b: "B"
        case .c: "C"
        }
    }

    var title: String { "Site \(letter)" }

    var color: Color {
        switch self {
        case .a: Color(red: 0.18, green: 0.43, blue: 0.70)
        case .b: Color(red: 0.72, green: 0.38, blue: 0.22)
        case .c: Color(red: 0.38, green: 0.51, blue: 0.25)
        }
    }
}

struct SettlementSite: Identifiable {
    let id: SettlementSiteID
    let name: String
    let subtitle: String
    let cells: [SettlementCell]
    let pattern: SettlementPattern
    let color: Color
    let bestFor: String
    let tradeoff: String
    let event: PlannerEvent

    var cellLabels: String {
        cells.map(\.label).joined(separator: ", ")
    }
}

struct PlannerEventOption: Identifiable {
    let id: String
    let text: String
}

struct PlannerEvent {
    let title: String
    let symbol: String
    let prompt: String
    let options: [PlannerEventOption]
    let correctOptionID: String
    let reveal: String
    let evidence: String
}

// MARK: - Map features

enum SettlementFeatureArtwork {
    case school
    case market
    case cafe
    case workshop
    case farm
    case office
    case home
}

struct SettlementFeature: Identifiable {
    let id: String
    let title: String
    let cell: SettlementCell
    let artwork: SettlementFeatureArtwork
    let widthInCells: CGFloat
    let sector: String?
}

// MARK: - Services

struct SettlementService: Identifiable {
    let id: String
    let title: String
    let cell: SettlementCell?
    let symbol: String
    let imageName: String?
    let isTown: Bool
    let note: String
}

struct ServiceDistance: Identifiable {
    let service: SettlementService
    let distance: Int

    var id: String { service.id }
    var withinWalk: Bool { distance <= SettlementMapData.walkLimit }
}

// MARK: - Assessment

struct SiteAssessment {
    let pattern: SettlementPattern
    let roadAccess: String
    let servicesWithinWalk: Int
    let serviceSummary: String
    let farmlandLost: Int
    let floodRisk: SettlementRisk
    let character: String
    let evidence: [String]
    let bestFor: String
    let tradeoff: String
}

// MARK: - Hierarchy and sectors

enum SettlementHierarchyLevel: String, CaseIterable, Identifiable {
    case isolatedDwelling
    case hamlet
    case village
    case smallTown
    case largeTown
    case city
    case conurbation

    var id: String { rawValue }

    var title: String {
        switch self {
        case .isolatedDwelling: "Isolated dwelling"
        case .hamlet: "Hamlet"
        case .village: "Village"
        case .smallTown: "Small town"
        case .largeTown: "Large town"
        case .city: "City"
        case .conurbation: "Conurbation"
        }
    }

    var populationLabel: String {
        switch self {
        case .isolatedDwelling: "One household"
        case .hamlet: "A few households"
        case .village: "Hundreds"
        case .smallTown: "Thousands"
        case .largeTown: "Tens of thousands"
        case .city: "Hundreds of thousands"
        case .conurbation: "Millions"
        }
    }

    var symbol: String {
        switch self {
        case .isolatedDwelling: "house.fill"
        case .hamlet: "house.lodge.fill"
        case .village: "building.2.fill"
        case .smallTown: "building.2.crop.circle.fill"
        case .largeTown: "building.columns.fill"
        case .city: "building.2.crop.circle"
        case .conurbation: "square.grid.3x3.fill"
        }
    }
}

enum SettlementSector: String, CaseIterable, Identifiable {
    case primary
    case secondary
    case tertiary
    case quaternary

    var id: String { rawValue }

    var title: String {
        switch self {
        case .primary: "Primary"
        case .secondary: "Secondary"
        case .tertiary: "Tertiary"
        case .quaternary: "Quaternary"
        }
    }

    var examples: String {
        switch self {
        case .primary: "Farm"
        case .secondary: "Workshop"
        case .tertiary: "Market, café, school"
        case .quaternary: "Planning office"
        }
    }

    var symbol: String {
        switch self {
        case .primary: "leaf.fill"
        case .secondary: "hammer.fill"
        case .tertiary: "cart.fill"
        case .quaternary: "brain.head.profile"
        }
    }

    var color: Color {
        switch self {
        case .primary: Color(red: 0.30, green: 0.55, blue: 0.27)
        case .secondary: Color(red: 0.76, green: 0.45, blue: 0.20)
        case .tertiary: Color(red: 0.19, green: 0.43, blue: 0.72)
        case .quaternary: Color(red: 0.47, green: 0.33, blue: 0.63)
        }
    }
}

// MARK: - Static map

enum SettlementMapData {
    static let size = 8
    static let columnLetters = ["A", "B", "C", "D", "E", "F", "G", "H"]
    static let walkLimit = 4
    static let householdSize = 4
    static let existingHomes = 2
    static let newHomes = 3

    static func cell(_ column: Int, _ row: Int) -> SettlementCell {
        SettlementCell(column: column, row: row)
    }

    static let schoolCell = cell(3, 2)
    static let marketCell = cell(7, 4)
    static let cafeCell = cell(7, 3)

    static let sites: [SettlementSite] = [
        SettlementSite(
            id: .a,
            name: "Central crossroads",
            subtitle: "Next to the school and main road",
            cells: [cell(2, 2), cell(2, 3), cell(3, 3)],
            pattern: .nucleated,
            color: SettlementSiteID.a.color,
            bestFor: "Families who need the school and a central location.",
            tradeoff: "It uses central land that could serve other services, and the market is still a walk away.",
            event: PlannerEvent(
                title: "Roadworks close the main road",
                symbol: "road.lanes",
                prompt: "The council closes the main road for six weeks. What is the most likely effect on Site A?",
                options: [
                    PlannerEventOption(id: "a1", text: "Residents can still walk to the school, but market deliveries are delayed."),
                    PlannerEventOption(id: "a2", text: "The homes are cut off from every service."),
                    PlannerEventOption(id: "a3", text: "The homes flood because they are beside the river.")
                ],
                correctOptionID: "a1",
                reveal: "Site A is central and within walking distance of the school. The road closure slows deliveries to the market at H5, but it does not cut the homes off.",
                evidence: "The homes are at C3, C4 and D4. The school is at D3, one to two cells away."
            )
        ),
        SettlementSite(
            id: .b,
            name: "Riverside lane",
            subtitle: "Between the lane and the river",
            cells: [cell(5, 5), cell(5, 6), cell(5, 7)],
            pattern: .linear,
            color: SettlementSiteID.b.color,
            bestFor: "Market access and riverside views, if flood defences are built.",
            tradeoff: "The homes sit in the flood zone, and the single street is exposed to river flooding.",
            event: PlannerEvent(
                title: "Heavy rain raises the river",
                symbol: "cloud.heavyrain.fill",
                prompt: "Heavy rain makes the river rise. What is the main risk at Site B?",
                options: [
                    PlannerEventOption(id: "b1", text: "The homes flood because they sit beside the river."),
                    PlannerEventOption(id: "b2", text: "The homes lose three cells of farmland."),
                    PlannerEventOption(id: "b3", text: "The school closes because it is too far away.")
                ],
                correctOptionID: "b1",
                reveal: "Site B is a linear row beside the river at F6 to F8. Flood water can reach the homes, and the bridge at G5 may close, cutting residents off from the market.",
                evidence: "The river runs along column G. Site B is one cell from the river at F6, F7 and F8."
            )
        ),
        SettlementSite(
            id: .c,
            name: "Farmland edge",
            subtitle: "On farmland at the edge of the village",
            cells: [cell(0, 5), cell(0, 6), cell(2, 6)],
            pattern: .dispersed,
            color: SettlementSiteID.c.color,
            bestFor: "Cheap land and space, if the council accepts the trade-offs.",
            tradeoff: "It loses farmland, and the homes are far from the school and market.",
            event: PlannerEvent(
                title: "A new bus route opens",
                symbol: "bus.fill",
                prompt: "A new bus route opens along the farmland lane. What is the likely effect at Site C?",
                options: [
                    PlannerEventOption(id: "c1", text: "Services become easier to reach, but more farmland may be built on."),
                    PlannerEventOption(id: "c2", text: "The river floods the homes."),
                    PlannerEventOption(id: "c3", text: "The homes become a nucleated village.")
                ],
                correctOptionID: "c1",
                reveal: "The bus route improves access from the lane at B6 and B7. But scattered homes are expensive to serve, and new homes may take more farmland.",
                evidence: "Site C is at A6, A7 and C7. The school at D3 is six to seven cells away."
            )
        )
    ]

    static let features: [SettlementFeature] = [
        SettlementFeature(id: "school", title: "School", cell: schoolCell, artwork: .school, widthInCells: 1.25, sector: "Tertiary"),
        SettlementFeature(id: "market", title: "Market", cell: marketCell, artwork: .market, widthInCells: 1.35, sector: "Tertiary"),
        SettlementFeature(id: "cafe", title: "Café", cell: cafeCell, artwork: .cafe, widthInCells: 1.5, sector: "Tertiary"),
        SettlementFeature(id: "workshop", title: "Workshop", cell: cell(7, 5), artwork: .workshop, widthInCells: 1.25, sector: "Secondary"),
        SettlementFeature(id: "farm", title: "Farm", cell: cell(3, 5), artwork: .farm, widthInCells: 1.35, sector: "Primary"),
        SettlementFeature(id: "office", title: "Planning office", cell: cell(2, 1), artwork: .office, widthInCells: 1.1, sector: "Quaternary"),
        SettlementFeature(id: "home-a", title: "Home", cell: cell(0, 3), artwork: .home, widthInCells: 0.8, sector: nil),
        SettlementFeature(id: "home-b", title: "Home", cell: cell(1, 3), artwork: .home, widthInCells: 0.8, sector: nil)
    ]

    static let localServices: [SettlementService] = [
        SettlementService(id: "school", title: "School", cell: schoolCell, symbol: "graduationcap.fill", imageName: nil, isTown: false, note: "At D3, inside the village"),
        SettlementService(id: "market", title: "Market", cell: marketCell, symbol: "cart.fill", imageName: nil, isTown: false, note: "At H5, across the bridge"),
        SettlementService(id: "cafe", title: "Café", cell: cafeCell, symbol: "cup.and.saucer.fill", imageName: "SettlementCafe", isTown: false, note: "At H4, beside the market")
    ]

    static let townServices: [SettlementService] = [
        SettlementService(id: "mall", title: "Shopping mall", cell: nil, symbol: "bag.fill", imageName: "SettlementMall", isTown: true, note: "High-order service, about 30 minutes away"),
        SettlementService(id: "hospital", title: "Hospital", cell: nil, symbol: "cross.case.fill", imageName: "SettlementHospital", isTown: true, note: "High-order service, about 30 minutes away")
    ]

    static func terrain(at cell: SettlementCell) -> SettlementTerrain {
        guard (0..<size).contains(cell.column), (0..<size).contains(cell.row) else {
            return .grass
        }

        if cell.column == 6 && cell.row == 4 { return .bridge }
        if cell.row == 4 { return .road }
        if cell.column == 6 { return .river }
        if cell.column == 4 && cell.row >= 5 { return .lane }
        if cell.column == 1 && cell.row >= 5 { return .lane }
        if cell.column == 7 && cell.row <= 2 { return .steep }
        if isWoods(cell) { return .woods }
        if isFarmland(cell) { return .farmland }
        return .grass
    }

    static func isWoods(_ cell: SettlementCell) -> Bool {
        let woods = [
            SettlementCell(column: 0, row: 0), SettlementCell(column: 1, row: 0),
            SettlementCell(column: 0, row: 1), SettlementCell(column: 1, row: 1),
            SettlementCell(column: 7, row: 6), SettlementCell(column: 7, row: 7)
        ]
        return woods.contains(cell)
    }

    static func isFarmland(_ cell: SettlementCell) -> Bool {
        (0...4).contains(cell.column) && (5...7).contains(cell.row)
    }

    static func site(at cell: SettlementCell) -> SettlementSite? {
        sites.first { $0.cells.contains(cell) }
    }

    static func site(for id: SettlementSiteID) -> SettlementSite {
        sites.first { $0.id == id } ?? sites[0]
    }

    static func feature(at cell: SettlementCell) -> SettlementFeature? {
        features.first { $0.cell == cell }
    }

    static func isWalkable(_ cell: SettlementCell) -> Bool {
        guard (0..<size).contains(cell.column), (0..<size).contains(cell.row) else {
            return false
        }
        let terrain = terrain(at: cell)
        return terrain != .river && terrain != .steep
    }

    static func neighbors(of cell: SettlementCell) -> [SettlementCell] {
        [
            SettlementCell(column: cell.column - 1, row: cell.row),
            SettlementCell(column: cell.column + 1, row: cell.row),
            SettlementCell(column: cell.column, row: cell.row - 1),
            SettlementCell(column: cell.column, row: cell.row + 1)
        ].filter { (0..<size).contains($0.column) && (0..<size).contains($0.row) }
    }

    static func walkDistance(from start: SettlementCell, to end: SettlementCell) -> Int {
        if start == end { return 0 }

        var queue: [(cell: SettlementCell, distance: Int)] = [(start, 0)]
        var visited: Set<SettlementCell> = [start]
        var index = 0

        while index < queue.count {
            let current = queue[index]
            index += 1

            for neighbor in neighbors(of: current.cell) where isWalkable(neighbor) && !visited.contains(neighbor) {
                if neighbor == end {
                    return current.distance + 1
                }
                visited.insert(neighbor)
                queue.append((neighbor, current.distance + 1))
            }
        }

        return 99
    }

    static func minWalkDistance(from site: SettlementSite, to cell: SettlementCell) -> Int {
        site.cells.map { walkDistance(from: $0, to: cell) }.min() ?? 99
    }

    static func serviceDistances(for site: SettlementSite) -> [ServiceDistance] {
        localServices.compactMap { service in
            guard let cell = service.cell else { return nil }
            return ServiceDistance(service: service, distance: minWalkDistance(from: site, to: cell))
        }
    }

    static func servicesWithinWalk(for site: SettlementSite) -> Int {
        serviceDistances(for: site).filter(\.withinWalk).count
    }

    static func serviceSummary(for site: SettlementSite) -> String {
        serviceDistances(for: site)
            .map { "\($0.service.title) \($0.distance == 1 ? "1 cell" : "\($0.distance) cells")" }
            .joined(separator: ", ")
    }

    static func farmlandLost(for site: SettlementSite) -> Int {
        site.cells.filter { terrain(at: $0) == .farmland }.count
    }

    static func floodRisk(for site: SettlementSite) -> SettlementRisk {
        let nearestRiver = site.cells.map { abs($0.column - 6) }.min() ?? 99
        switch nearestRiver {
        case 0...1: return .high
        case 2: return .moderate
        default: return .low
        }
    }

    static func roadAccessLabel(for site: SettlementSite) -> String {
        switch site.id {
        case .a: "On the main road"
        case .b: "On the riverside lane"
        case .c: "On the farm lane"
        }
    }

    static func character(for site: SettlementSite) -> String {
        switch site.id {
        case .a: "Central and service-rich"
        case .b: "Riverside and linear"
        case .c: "Rural and dispersed"
        }
    }

    static func assessment(for site: SettlementSite) -> SiteAssessment {
        let distances = serviceDistances(for: site)
        let within = distances.filter(\.withinWalk).count
        let farmland = farmlandLost(for: site)
        let risk = floodRisk(for: site)
        let road = roadAccessLabel(for: site)
        let serviceText = serviceSummary(for: site)

        let evidence = [
            "The homes at \(site.cellLabels) form a \(site.pattern.title.lowercased()) pattern.",
            "\(road). \(serviceText). Four cells is about a 10-minute walk.",
            farmland == 0 ? "No farmland is lost." : "\(farmland) farmland cells are lost.",
            "Flood risk is \(risk.title.lowercased()) because the nearest river cell is \(site.cells.map { abs($0.column - 6) }.min() ?? 99) cells away."
        ]

        return SiteAssessment(
            pattern: site.pattern,
            roadAccess: road,
            servicesWithinWalk: within,
            serviceSummary: serviceText,
            farmlandLost: farmland,
            floodRisk: risk,
            character: character(for: site),
            evidence: evidence,
            bestFor: site.bestFor,
            tradeoff: site.tradeoff
        )
    }

    static func hierarchy(for homes: Int) -> SettlementHierarchyLevel {
        switch homes {
        case 0...1: .isolatedDwelling
        case 2...9: .hamlet
        case 10...49: .village
        case 50...199: .smallTown
        case 200...999: .largeTown
        case 1000...9999: .city
        default: .conurbation
        }
    }

    static let hierarchyLevels: [SettlementHierarchyLevel] = [
        .isolatedDwelling, .hamlet, .village, .smallTown, .largeTown, .city, .conurbation
    ]

    static let sectors: [SettlementSector] = [.primary, .secondary, .tertiary, .quaternary]
}
