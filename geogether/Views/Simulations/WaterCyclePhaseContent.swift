import SwiftUI

extension WaterCycleEngine.Phase {
    var popupTitle: String {
        switch self {
        case .evaporation: "Evaporation"
        case .condensation: "Condensation"
        case .precipitation: "Precipitation"
        case .collection: "Collection & Runoff"
        }
    }

    var explanation: String {
        switch self {
        case .evaporation:
            "Heat from the sun warms water in the ocean, turning liquid water into invisible water vapor that rises into the air."
        case .condensation:
            "As warm water vapor rises and cools higher in the atmosphere, it gathers around tiny particles to form clouds."
        case .precipitation:
            "When cloud droplets grow too heavy to stay suspended in the air, they fall back to land and sea as rain."
        case .collection:
            "Rainwater collects in streams and flows across the land as runoff, returning water back to the ocean to repeat the cycle."
        }
    }
}
