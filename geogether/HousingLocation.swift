import SwiftUI

enum HousingLocation: String, CaseIterable, Identifiable {
    case community, homes, dining, school, playground, garden

    var id: String { rawValue }

    var title: LocalizedStringResource {
        switch self {
        case .community: "Community Centre"
        case .homes: "Public Housing"
        case .dining: "Hawker Center"
        case .school: "School"
        case .playground: "Playground"
        case .garden: "Park"
        }
    }

    var artworkName: String {
        switch self {
        case .community: "CommunityCentre"
        case .homes: "PublicHousing"
        case .dining: "HawkerCenter"
        case .school: "School"
        case .playground: "Playground"
        case .garden: "Park"
        }
    }

    var symbol: String {
        switch self {
        case .community: "person.3.fill"
        case .homes: "building.2.fill"
        case .dining: "fork.knife"
        case .school: "graduationcap.fill"
        case .playground: "figure.play"
        case .garden: "tree.fill"
        }
    }

    // Normalized bounds in the original square map image.
    var mapBounds: CGRect {
        switch self {
        case .community: CGRect(x: 0.04, y: 0.31, width: 0.24, height: 0.16)
        case .homes: CGRect(x: 0.33, y: 0.38, width: 0.18, height: 0.15)
        case .dining: CGRect(x: 0.42, y: 0.24, width: 0.25, height: 0.16)
        case .school: CGRect(x: 0.57, y: 0.37, width: 0.35, height: 0.19)
        case .playground: CGRect(x: 0.42, y: 0.53, width: 0.15, height: 0.12)
        case .garden: CGRect(x: 0.57, y: 0.67, width: 0.11, height: 0.12)
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
