import SwiftUI

private struct EmbeddedSimulationKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var isEmbeddedSimulation: Bool {
        get { self[EmbeddedSimulationKey.self] }
        set { self[EmbeddedSimulationKey.self] = newValue }
    }
}

enum SimulationDestination: String, CaseIterable, Identifiable, Hashable {
    case geoWorld
    case urbanRural
    case waterCycle
    case settlements
    case mangroveRoots
    case housing

    var id: Self { self }

    var title: String {
        switch self {
        case .geoWorld: return "GeoPaws open world"
        case .urbanRural: return "Urban and rural"
        case .waterCycle: return "Water distribution"
        case .settlements: return "Settlement hierarchy"
        case .mangroveRoots: return "Mangrove roots"
        case .housing: return "Sustainable housing"
        }
    }

    var subtitle: String {
        switch self {
        case .geoWorld: return "Explore the map, meet characters and complete quests"
        case .urbanRural: return "Compare homes, land and services"
        case .waterCycle: return "Follow water through each stage of the cycle"
        case .settlements: return "See how population and services change"
        case .mangroveRoots: return "Find out what each type of root does"
        case .housing: return "Add four changes to a neighbourhood"
        }
    }

    var symbol: String {
        switch self {
        case .geoWorld: return "gamecontroller.fill"
        case .urbanRural: return "building.2.fill"
        case .waterCycle: return "drop.fill"
        case .settlements: return "house.fill"
        case .mangroveRoots: return "tree.fill"
        case .housing: return "house.and.flag.fill"
        }
    }

    var tint: Color {
        switch self {
        case .geoWorld: return .indigo
        case .urbanRural: return .purple
        case .waterCycle: return .blue
        case .settlements: return Color(red: 0.04, green: 0.47, blue: 0.51)
        case .mangroveRoots: return .green
        case .housing: return .orange
        }
    }

    @ViewBuilder
    var view: some View {
        switch self {
        case .geoWorld: GeoWorldView()
        case .urbanRural: HousingCompareView()
        case .waterCycle: WaterCycleView()
        case .settlements: SettlementHierarchyView()
        case .mangroveRoots: MangroveRootsView()
        case .housing: HousingSolutionsView()
        }
    }
}
