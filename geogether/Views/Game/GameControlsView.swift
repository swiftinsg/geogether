import SwiftUI

struct GameControlsView: View {
    let onMove: (CGVector) -> Void
    let openSimulations: () -> Void
    let openQuickStudy: () -> Void

    var body: some View {
        HStack(alignment: .bottom) {
            VirtualJoystick(onMove: onMove)

            Spacer(minLength: 12)

            VStack(alignment: .trailing, spacing: 8) {
                Text("WASD, arrow keys or joystick")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.black.opacity(0.45), in: Capsule())

                if #available(iOS 26.0, *) {
                    GlassEffectContainer(spacing: 12) {
                        HStack(spacing: 12) {
                            simulationButton
                                .glassEffect(.regular.tint(.blue.opacity(0.28)).interactive(), in: .circle)
                            quickStudyButton
                                .glassEffect(.regular.tint(.blue.opacity(0.42)).interactive(), in: .circle)
                        }
                    }
                } else {
                    HStack(spacing: 12) {
                        simulationButton
                            .background(.ultraThinMaterial, in: Circle())
                        quickStudyButton
                            .background(.blue, in: Circle())
                    }
                }
            }
        }
    }

    private var simulationButton: some View {
        Button(action: openSimulations) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white.opacity(0.72), .blue.opacity(0.42), .indigo.opacity(0.3)],
                            center: .topLeading,
                            startRadius: 2,
                            endRadius: 42
                        )
                    )

                VStack(spacing: 2) {
                    Image(systemName: "sparkles")
                        .font(.title2.bold())
                    Text("SIMS")
                        .font(.system(size: 9, weight: .bold))
                }
                .foregroundStyle(.white)
            }
            .frame(width: 76, height: 76)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open simulations")
        .accessibilityHint("Shows the app simulations without leaving the game")
    }

    private var quickStudyButton: some View {
        Button(action: openQuickStudy) {
            VStack(spacing: 2) {
                Image(systemName: "book.closed.fill")
                    .font(.title2)
                Text("STUDY")
                    .font(.system(size: 9, weight: .bold))
            }
            .frame(width: 76, height: 76)
            .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open Quick Study")
    }
}

struct VirtualJoystick: View {
    let onMove: (CGVector) -> Void

    @State private var knobOffset = CGSize.zero

    private let maxRadius: CGFloat = 42

    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 110, height: 110)
                .overlay(Circle().stroke(.white.opacity(0.4), lineWidth: 2))

            Circle()
                .fill(.white.opacity(0.85))
                .frame(width: 44, height: 44)
                .offset(knobOffset)
                .gesture(joystickGesture)
        }
        .accessibilityLabel("Movement joystick")
    }

    private var joystickGesture: some Gesture {
        DragGesture()
            .onChanged(updatePosition)
            .onEnded { _ in
                withAnimation(.spring()) {
                    knobOffset = .zero
                }
                onMove(.zero)
            }
    }

    private func updatePosition(_ value: DragGesture.Value) {
        let dx = value.translation.width
        let dy = value.translation.height
        let distance = hypot(dx, dy)

        if distance <= maxRadius {
            knobOffset = value.translation
        } else {
            let angle = atan2(dy, dx)
            knobOffset = CGSize(width: cos(angle) * maxRadius, height: sin(angle) * maxRadius)
        }

        onMove(CGVector(dx: knobOffset.width / maxRadius, dy: -knobOffset.height / maxRadius))
    }
}
