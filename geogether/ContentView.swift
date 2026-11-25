import SwiftUI

struct ContentView: View {
    private let darkBlue = Color(red: 0.03, green: 0.18, blue: 0.35)

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    MovingBlueBackground()

                    WaterScene()
                        .ignoresSafeArea()

                    VStack(spacing: 40) {
                        WelcomeHeading()
                            .foregroundStyle(.white)
                            .shadow(color: darkBlue.opacity(0.45), radius: 8, y: 3)
                            .padding(20)
                            .padding(.top, min(geometry.size.height * 0.14, 104))

                        Spacer(minLength: 40)

                        NavigationLink {
                            TopicSelectionView()
                        } label: {
                            HStack(spacing: 12) {
                                Text("Start Adventure")
                                Image(systemName: "arrow.right")
                            }
                            .font(.system(.title2, design: .default, weight: .bold))
                            .foregroundStyle(darkBlue)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 20)
                            .background(.white, in: Capsule())
                            .shadow(color: darkBlue.opacity(0.22), radius: 14, y: 7)
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom, 44)
                    }
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
        }
        .preferredColorScheme(.light)
    }
}

private struct WelcomeHeading: View {
    @ScaledMetric(relativeTo: .largeTitle) private var titleSize = 60

    var body: some View {
        VStack(spacing: -5) {
            Text("Welcome to")
                .font(.system(.largeTitle, weight: .bold))

            Text(verbatim: "Geogworld")
                .kerning(-1)
                .font(.system(size: titleSize, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
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
