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
                        .font(.system(size: 42, weight: .medium))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.2), radius: 8, y: 3)
                        .position(touchLocation)
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
