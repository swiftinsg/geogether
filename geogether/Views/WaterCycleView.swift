import SwiftUI

/// Animated water-cycle lesson adapted from the `kudasyroba` prototype.
struct WaterCycleView: View {
    private enum Mode: String, CaseIterable, Identifiable {
        case animate = "Animate"
        case scrub = "Slider"

        var id: Self { self }
    }

    @State private var mode = Mode.animate
    @State private var scrub = 0.0
    @State private var startDate = Date()

    private let transferColor = Color(red: 0.98, green: 0.45, blue: 0.52)
    private let storeColor = Color(red: 0.45, green: 0.90, blue: 0.95)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Picker("Playback mode", selection: $mode) {
                    ForEach(Mode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                GeometryReader { geometry in
                    TimelineView(.animation) { timeline in
                        let phase = mode == .animate
                            ? cycleFraction(timeline.date.timeIntervalSince(startDate) / 14)
                            : scrub
                        WaterCycleScene(
                            phase: phase,
                            size: geometry.size,
                            transferColor: transferColor,
                            storeColor: storeColor
                        )
                    }
                }
                .frame(height: 430)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)

                if mode == .scrub {
                    VStack(spacing: 5) {
                        Slider(value: $scrub, in: 0...1)
                        HStack {
                            Text("Evaporation")
                            Spacer()
                            Text("Rain")
                            Spacer()
                            Text("Flow")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }

                TimelineView(.periodic(from: .now, by: 0.25)) { timeline in
                    let phase = mode == .animate
                        ? cycleFraction(timeline.date.timeIntervalSince(startDate) / 14)
                        : scrub
                    StageCard(stage: WaterCycleStage.stage(for: phase), tint: transferColor)
                }

                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .top, spacing: 12) { keyCards }
                    VStack(spacing: 12) { keyCards }
                }
            }
            .padding(20)
        }
        .background(AnimatedOceanBackground())
        .navigationTitle("The water cycle")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: mode) { _, newMode in
            if newMode == .animate { startDate = Date() }
        }
    }

    @ViewBuilder
    private var keyCards: some View {
        WaterCycleKeyCard(
            title: "Transfers",
            color: transferColor,
            items: ["Evaporation", "Condensation", "Precipitation", "Infiltration", "Groundwater flow"]
        )
        WaterCycleKeyCard(
            title: "Stores",
            color: storeColor,
            items: ["Atmosphere", "Snow and ice", "Lake", "Sea", "Aquifer"]
        )
    }
}

private struct WaterCycleScene: View {
    let phase: Double
    let size: CGSize
    let transferColor: Color
    let storeColor: Color

    private var raining: Bool { (0.42...0.72).contains(phase) }
    private var flowStrength: Double { smoothStep(phase, from: 0.70, to: 1) }

    var body: some View {
        let width = size.width
        let height = size.height

        ZStack {
            LinearGradient(
                colors: [Color(red: 0.62, green: 0.85, blue: 0.99), Color(red: 0.90, green: 0.97, blue: 1)],
                startPoint: .top,
                endPoint: .bottom
            )

            Circle()
                .fill(.yellow)
                .frame(width: 46, height: 46)
                .shadow(color: .yellow.opacity(0.6), radius: 12)
                .position(x: width * 0.86, y: height * 0.12)

            Rectangle()
                .fill(Color(red: 0.55, green: 0.45, blue: 0.35))
                .frame(width: width, height: height * 0.26)
                .position(x: width / 2, y: height * 0.87)
            Rectangle()
                .fill(Color(red: 0.85, green: 0.78, blue: 0.62))
                .frame(width: width, height: height * 0.09)
                .position(x: width / 2, y: height * 0.90)

            mountain(width: width, height: height)

            Ellipse()
                .fill(Color(red: 0.35, green: 0.72, blue: 0.35))
                .frame(width: width * 1.25, height: height * 0.52)
                .position(x: width * 0.78, y: height * 0.88)

            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.40, green: 0.85, blue: 0.95), Color(red: 0.15, green: 0.65, blue: 0.90)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: width * 0.42, height: height * 0.10)
                .position(x: width * 0.79, y: height * 0.695)

            storeLabel("SEA", x: width * 0.79, y: height * 0.695)
            storeLabel("AQUIFER", x: width * 0.14, y: height * 0.90)

            Ellipse()
                .fill(storeColor)
                .frame(width: width * 0.17, height: height * 0.04)
                .position(x: width * 0.40, y: height * 0.625)

            Image(systemName: "tree.fill")
                .font(.system(size: 42))
                .foregroundStyle(Color(red: 0.10, green: 0.50, blue: 0.22))
                .position(x: width * 0.56, y: height * 0.545)
            Image(systemName: "tree.fill")
                .font(.system(size: 32))
                .foregroundStyle(Color(red: 0.15, green: 0.58, blue: 0.28))
                .position(x: width * 0.65, y: height * 0.60)

            vapour(width: width, height: height)
            cloud(width: width, height: height)
            rain(width: width, height: height)
            groundwater(width: width, height: height)

            Label(WaterCycleStage.stage(for: phase).name.uppercased(), systemImage: "arrow.triangle.2.circlepath")
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color(red: 0.55, green: 0.15, blue: 0.20))
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(Capsule().fill(.white.opacity(0.88)))
                .position(x: width * 0.24, y: height * 0.055)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Animated water cycle diagram")
        .accessibilityValue(WaterCycleStage.stage(for: phase).detail)
    }

    private func mountain(width: CGFloat, height: CGFloat) -> some View {
        Path { path in
            path.move(to: CGPoint(x: -10, y: height * 0.64))
            path.addLine(to: CGPoint(x: width * 0.22, y: height * 0.24))
            path.addLine(to: CGPoint(x: width * 0.46, y: height * 0.64))
            path.closeSubpath()
        }
        .fill(Color(red: 0.25, green: 0.65, blue: 0.30))
    }

    private func cloud(width: CGFloat, height: CGFloat) -> some View {
        let condensation = smoothStep(phase, from: 0.18, to: 0.40) * (1 - smoothStep(phase, from: 0.45, to: 0.60))
        return ZStack {
            Image(systemName: "cloud.fill").font(.system(size: 92))
            Image(systemName: "cloud.fill").font(.system(size: 62)).offset(x: -58, y: 12)
            Image(systemName: "cloud.fill").font(.system(size: 56)).offset(x: 60, y: 14)
        }
        .foregroundStyle(.white)
        .shadow(color: .gray.opacity(0.25), radius: 6, y: 3)
        .scaleEffect(0.85 + condensation * 0.35)
        .position(x: width * 0.30, y: height * 0.15)
    }

    @ViewBuilder
    private func vapour(width: CGFloat, height: CGFloat) -> some View {
        ForEach(0..<7, id: \.self) { index in
            let seed = cycleFraction(sin(Double(index) * 12.9898) * 43758.5453)
            let progress = cycleFraction(phase * 2.5 + seed * 5)
            Circle()
                .fill(.white.opacity(0.75 * (1 - progress)))
                .frame(width: 7 + seed * 8, height: 7 + seed * 8)
                .position(x: width * (0.62 + seed * 0.33), y: height * (0.65 - progress * 0.33))
        }
    }

    @ViewBuilder
    private func rain(width: CGFloat, height: CGFloat) -> some View {
        if raining {
            ForEach(0..<26, id: \.self) { index in
                let seed = cycleFraction(sin(Double(index) * 12.9898) * 43758.5453)
                let progress = cycleFraction(phase * 2.4 + seed * 7)
                Capsule()
                    .fill(Color.blue.opacity(0.75))
                    .frame(width: 2.5, height: 12)
                    .position(
                        x: width * (0.13 + seed * 0.34),
                        y: height * (0.24 + progress * (0.46 + seed * 0.17 - 0.24))
                    )
            }
        }
    }

    @ViewBuilder
    private func groundwater(width: CGFloat, height: CGFloat) -> some View {
        ForEach(0..<4, id: \.self) { index in
            let progress = cycleFraction(flowStrength * 1.2 + Double(index) * 0.25)
            Circle()
                .fill(Color.blue.opacity(phase > 0.68 ? 0.9 : 0.15))
                .frame(width: 7, height: 7)
                .position(x: width * (0.08 + progress * 0.80), y: height * 0.90)
        }
    }

    private func storeLabel(_ text: String, x: CGFloat, y: CGFloat) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(AppPalette.navy)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(RoundedRectangle(cornerRadius: 4).fill(storeColor))
            .position(x: x, y: y)
    }

    private func smoothStep(_ value: Double, from start: Double, to end: Double) -> Double {
        min(max((value - start) / (end - start), 0), 1)
    }
}

private struct WaterCycleStage {
    let name: String
    let detail: String

    static func stage(for phase: Double) -> Self {
        switch phase {
        case ..<0.25:
            return Self(name: "Evaporation", detail: "The sun heats water in the sea, lakes and land. Water vapour rises into the atmosphere.")
        case ..<0.45:
            return Self(name: "Condensation", detail: "Water vapour cools and condenses into tiny droplets that form clouds.")
        case ..<0.72:
            return Self(name: "Precipitation", detail: "Water droplets join and fall to Earth as rain, snow or ice.")
        default:
            return Self(name: "Flow and storage", detail: "Water flows over land or soaks into the ground before returning to lakes and seas.")
        }
    }
}

private struct StageCard: View {
    let stage: WaterCycleStage
    let tint: Color

    var body: some View {
        QuizCard {
            VStack(alignment: .leading, spacing: 7) {
                Label(stage.name, systemImage: "drop.fill")
                    .font(.headline)
                    .foregroundStyle(AppPalette.navy)
                Text(stage.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct WaterCycleKeyCard: View {
    let title: String
    let color: Color
    let items: [String]

    var body: some View {
        QuizCard {
            VStack(alignment: .leading, spacing: 6) {
                Label(title, systemImage: title == "Stores" ? "archivebox.fill" : "arrow.right")
                    .font(.headline)
                    .foregroundStyle(AppPalette.navy)
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 16, height: 16)
                .padding(16)
        }
    }
}

private func cycleFraction(_ value: Double) -> Double {
    value - floor(value)
}

#Preview {
    NavigationStack { WaterCycleView() }
}
