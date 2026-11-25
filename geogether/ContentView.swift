import SwiftUI

struct ContentView: View {
    @State private var isAdventureStarted = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.80, green: 0.95, blue: 0.99),
                        Color(red: 0.38, green: 0.78, blue: 0.91),
                        Color(red: 0.08, green: 0.43, blue: 0.72)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                WaterScene()
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    VStack(spacing: 12) {
                        Text("YOUR NEXT JOURNEY STARTS HERE")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .tracking(2.2)
                            .foregroundStyle(.white.opacity(0.85))

                        HStack(spacing: 0) {
                            Text("Welcome to")
                                .padding(.trailing, 9)
                            Text("Geogw")
                            Image(systemName: "globe.americas.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(Color(red: 0.10, green: 0.62, blue: 0.76), .white)
                                .font(.system(size: 34, weight: .bold))
                                .padding(.horizontal, 1)
                                .accessibilityLabel("o")
                            Text("rld")
                        }
                        .font(.system(size: min(geometry.size.width * 0.085, 36), weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.15), radius: 12, y: 4)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .accessibilityElement(children: .combine)

                        Text("Discover amazing places, one adventure at a time.")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 28)
                    }
                    .padding(.horizontal, 18)

                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            isAdventureStarted.toggle()
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Text(isAdventureStarted ? "Let’s explore!" : "Start an adventure")
                            Image(systemName: isAdventureStarted ? "location.north.fill" : "arrow.right")
                        }
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.04, green: 0.34, blue: 0.58))
                        .padding(.horizontal, 28)
                        .padding(.vertical, 17)
                        .background(.white, in: Capsule())
                        .shadow(color: .black.opacity(0.18), radius: 14, y: 7)
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, max(geometry.safeAreaInsets.bottom, 28) + 30)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .preferredColorScheme(.light)
    }
}

private struct WaterScene: View {
    var body: some View {
        GeometryReader { geometry in
            TimelineView(.animation) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate

                ZStack {
                    Wave(phase: time * 1.1, amplitude: 18, baseline: 0.66)
                        .fill(Color(red: 0.08, green: 0.59, blue: 0.82).opacity(0.78))
                    Wave(phase: time * 0.8 + 2, amplitude: 22, baseline: 0.74)
                        .fill(Color(red: 0.04, green: 0.48, blue: 0.76).opacity(0.88))
                    Wave(phase: time * 1.3 + 4, amplitude: 16, baseline: 0.82)
                        .fill(Color(red: 0.02, green: 0.35, blue: 0.66).opacity(0.94))

                    ForEach(0..<18, id: \.self) { index in
                        Bubble(index: index, time: time, size: geometry.size)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
        }
    }
}

private struct Wave: Shape {
    var phase: Double
    var amplitude: CGFloat
    var baseline: CGFloat

    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let baseY = rect.height * baseline
        path.move(to: CGPoint(x: 0, y: baseY))

        for x in stride(from: CGFloat.zero, through: rect.width, by: 2) {
            let relativeX = x / rect.width
            let y = baseY
                + sin(relativeX * .pi * 2 + phase) * amplitude
                + sin(relativeX * .pi * 4 - phase * 0.7) * amplitude * 0.35
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

private struct Bubble: View {
    let index: Int
    let time: TimeInterval
    let size: CGSize

    private var progress: CGFloat {
        let duration = 5.0 + Double(index % 5) * 1.1
        let offset = Double(index) * 0.71
        return CGFloat((time / duration + offset).truncatingRemainder(dividingBy: 1))
    }

    var body: some View {
        let diameter = CGFloat(5 + (index % 4) * 3)
        let x = size.width * CGFloat((index * 37 % 97) + 2) / 100
        let y = size.height * (1 - progress)

        Circle()
            .fill(.white.opacity(0.55))
            .overlay(Circle().stroke(.white.opacity(0.7), lineWidth: 1))
            .frame(width: diameter, height: diameter)
            .position(x: x, y: y)
            .blur(radius: index.isMultiple(of: 3) ? 0.5 : 0)
    }
}

#Preview {
    ContentView()
}
