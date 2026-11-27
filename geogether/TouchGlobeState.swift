import Combine
import SwiftUI

/// Lets screens hide the globe touch marker while they use their own drag gesture.
@MainActor
final class TouchGlobeState: ObservableObject {
    @Published var isSuppressed = false
}
