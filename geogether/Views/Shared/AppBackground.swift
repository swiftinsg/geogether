import SwiftUI

/// Soft background that echoes the colour of the current topic.
struct AppBackground: View {
    var tint: Color = TopicTint.teal.color

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
            RadialGradient(
                colors: [tint.opacity(0.20), tint.opacity(0.05), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 560
            )
        }
        .ignoresSafeArea()
    }
}
