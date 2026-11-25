import SwiftUI

enum HousingLocation: String, CaseIterable, Identifiable {
    case community, homes, dining, school, playground, garden

    var id: String { rawValue }

    var title: LocalizedStringResource {
        switch self {
        case .community: "Community centre"
        case .homes: "Homes"
        case .dining: "Dining area"
        case .school: "School"
        case .playground: "Playground"
        case .garden: "Community garden"
        }
    }

    var symbol: String {
        switch self {
        case .community: "person.3.fill"
        case .homes: "building.2.fill"
        case .dining: "fork.knife"
        case .school: "graduationcap.fill"
        case .playground: "figure.play"
        case .garden: "leaf.fill"
        }
    }

    // Positions use the city artwork's 720 × 1100 coordinate space.
    var mapCenter: CGPoint {
        switch self {
        case .community: CGPoint(x: 119, y: 175)
        case .homes: CGPoint(x: 360, y: 175)
        case .dining: CGPoint(x: 360, y: 520)
        case .school: CGPoint(x: 600, y: 520)
        case .playground: CGPoint(x: 119, y: 885)
        case .garden: CGPoint(x: 600, y: 885)
        }
    }

    var color: Color {
        switch self {
        case .community: Color(red: 0.22, green: 0.46, blue: 0.67)
        case .homes: Color(red: 0.22, green: 0.45, blue: 0.40)
        case .dining: Color(red: 0.67, green: 0.36, blue: 0.20)
        case .school: Color(red: 0.65, green: 0.28, blue: 0.29)
        case .playground: Color(red: 0.44, green: 0.35, blue: 0.62)
        case .garden: Color(red: 0.29, green: 0.48, blue: 0.24)
        }
    }
}
