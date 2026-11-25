import SwiftUI

struct GlobeTouchView<Content: View>: View {
    @GestureState private var touchLocation: CGPoint?
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .contentShape(Rectangle())
            .overlay(alignment: .topLeading) {
                if let touchLocation {
                    Image(systemName: "globe")
                        .font(.system(size: 56, weight: .semibold))
                        .foregroundStyle(.black)
                        .position(x: touchLocation.x, y: max(32, touchLocation.y - 110))
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            // Observe alongside buttons and scrolling, and reset even if a touch is cancelled.
            .simultaneousGesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .updating($touchLocation) { value, location, _ in
                        location = value.location
                    }
            )
    }
}
