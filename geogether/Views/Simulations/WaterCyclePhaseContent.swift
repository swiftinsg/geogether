import SwiftUI

extension WaterCycleEngine.Phase {
    var popupTitle: String {
        switch self {
        case .evaporation: "Evaporation"
        case .condensation: "Condensation"
        case .precipitation: "Precipitation"
        case .collection: "Collection and runoff"
        }
    }

    var explanation: String {
        switch self {
        case .evaporation:
            "The sun warms the ocean. Liquid water becomes water vapour and rises into the air."
        case .condensation:
            "Water vapour cools as it rises. It condenses around tiny particles in the air and forms clouds."
        case .precipitation:
            "Water droplets join together inside the cloud. When they become too heavy, they fall as rain."
        case .collection:
            "Rain collects in streams or flows over the ground as runoff. It returns to the ocean, and the cycle starts again."
        }
    }
}
