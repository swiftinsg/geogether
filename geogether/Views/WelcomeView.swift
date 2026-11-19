import SwiftUI

/// Opening screen adapted from the `kudasyroba` prototype.
struct WelcomeView: View {
    @State private var showTitle = false
    @State private var showButton = false
    @State private var waterStart = Date()
    @State private var showTopics = false

    var body: some View {
        ZStack {
            if showTopics {
                TopicListView {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        showTopics = false
                    }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                welcome
                    .transition(.opacity)
            }
        }
    }

    private var welcome: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.85, green: 0.95, blue: 1), .white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            RisingWaterView(start: waterStart)
                .ignoresSafeArea()
                .accessibilityHidden(true)

            VStack(spacing: 0) {
                Spacer().frame(height: 100)

                VStack(spacing: 4) {
                    Text("Welcome to Geogether")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(AppPalette.navy)
                        .multilineTextAlignment(.center)

                    Text("Geography, together")
                        .font(.system(size: 17))
                        .italic()
                        .foregroundStyle(AppPalette.navy.opacity(0.7))
                }
                .padding(.horizontal, 24)
                .scaleEffect(showTitle ? 1 : 0.3)
                .opacity(showTitle ? 1 : 0)
                .offset(y: showTitle ? 0 : 40)
                .contentShape(Rectangle())
                .onTapGesture(perform: replayAnimation)

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        showTopics = true
                    }
                } label: {
                    Text("Continue your adventure")
                        .font(.headline)
                        .foregroundStyle(AppPalette.blue)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 15)
                        .background(Capsule().fill(.white))
                        .shadow(color: .black.opacity(0.22), radius: 8, y: 4)
                }
                .buttonStyle(.plain)
                .opacity(showButton ? 1 : 0)
                .scaleEffect(showButton ? 1 : 0.6)
                .offset(y: showButton ? 0 : 30)
                .padding(.bottom, 50)
            }
            .onAppear(perform: startAnimation)
        }
    }

    private func startAnimation() {
        withAnimation(.spring(response: 0.55, dampingFraction: 0.55).delay(1.15)) {
            showTitle = true
        }
        withAnimation(.spring(response: 0.55, dampingFraction: 0.6).delay(2.4)) {
            showButton = true
        }
    }

    private func replayAnimation() {
        showTitle = false
        showButton = false
        waterStart = Date()
        startAnimation()
    }
}

private struct RisingWaterView: View {
    let start: Date
    var fillAmount = 0.55
    var riseDuration = 2.4

    var body: some View {
        GeometryReader { geometry in
            TimelineView(.animation) { timeline in
                let elapsed = timeline.date.timeIntervalSince(start)
                let raw = min(max(elapsed / riseDuration, 0), 1)
                let level = fillAmount * (1 - pow(1 - raw, 3))
                let time = timeline.date.timeIntervalSinceReferenceDate

                ZStack {
                    WaterWaveShape(phase: time * 1.1, level: level * 0.96, amplitude: 15)
                        .fill(.cyan.opacity(0.35))
                    WaterWaveShape(phase: -time * 1.7, level: level, amplitude: 10)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.10, green: 0.55, blue: 0.95), AppPalette.blue],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    ForEach(0..<14, id: \.self) { index in
                        let xFraction = fraction(sin(Double(index) * 12.9898) * 43758.5453)
                        let speed = 0.10 + fraction(sin(Double(index) * 3.7) * 24634.6) * 0.10
                        let cycle = fraction(time * speed + xFraction * 7)
                        let waterTop = geometry.size.height * (1 - level)
                        let y = geometry.size.height - 12 - cycle * max(geometry.size.height - waterTop - 24, 0)

                        Circle()
                            .fill(.white.opacity(0.35 * (1 - cycle)))
                            .frame(width: 6 + xFraction * 12, height: 6 + xFraction * 12)
                            .position(
                                x: xFraction * geometry.size.width,
                                y: level > 0.03 ? y : geometry.size.height + 30
                            )
                    }
                }
            }
        }
    }

    private func fraction(_ value: Double) -> Double {
        value - floor(value)
    }
}

private struct WaterWaveShape: Shape {
    var phase: Double
    var level: Double
    var amplitude: Double

    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(phase, level) }
        set {
            phase = newValue.first
            level = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let surfaceY = rect.height * (1 - level)
        path.move(to: CGPoint(x: 0, y: surfaceY))

        for x in stride(from: CGFloat.zero, through: rect.width, by: 8) {
            let position = Double(x / rect.width)
            let y = surfaceY + CGFloat(sin(position * .pi * 4 + phase) * amplitude)
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

#Preview {
    WelcomeView()
        .environmentObject(ProgressStore())
}
