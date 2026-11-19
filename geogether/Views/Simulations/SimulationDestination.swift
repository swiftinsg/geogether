import SwiftUI

enum SimulationDestination: String, CaseIterable, Identifiable, Hashable {
    case urbanRural
    case waterCycle
    case settlements
    case mangroveRoots
    case housing

    var id: Self { self }

    var title: String {
        switch self {
        case .urbanRural: return "Urban and rural"
        case .waterCycle: return "Water distribution"
        case .settlements: return "Settlement hierarchy"
        case .mangroveRoots: return "Mangrove roots"
        case .housing: return "Sustainable housing"
        }
    }

    var subtitle: String {
        switch self {
        case .urbanRural: return "Slide between two ways of life"
        case .waterCycle: return "Track every drop from sea to sky and back"
        case .settlements: return "Grow a settlement from a home to a city"
        case .mangroveRoots: return "See how roots survive in soft, wet soil"
        case .housing: return "Turn housing problems into practical solutions"
        }
    }

    var symbol: String {
        switch self {
        case .urbanRural: return "building.2.fill"
        case .waterCycle: return "drop.fill"
        case .settlements: return "house.fill"
        case .mangroveRoots: return "tree.fill"
        case .housing: return "house.and.flag.fill"
        }
    }

    var tint: Color {
        switch self {
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
        case .urbanRural: HousingCompareView()
        case .waterCycle: WaterCycleView()
        case .settlements: SettlementHierarchyView()
        case .mangroveRoots: MangroveRootsView()
        case .housing: HousingSolutionsView()
        }
    }
}
