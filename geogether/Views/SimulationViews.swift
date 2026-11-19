import SwiftUI

struct SettlementHierarchyView: View {
    private struct Level {
        let name: String
        let population: String
        let services: String
        let buildings: Int
        let symbol: String
    }

    private let levels = [
        Level(name: "Isolated dwelling", population: "One household", services: "Residents travel elsewhere for most services.", buildings: 1, symbol: "house.fill"),
        Level(name: "Hamlet", population: "A few households", services: "Few or no permanent services.", buildings: 3, symbol: "house.fill"),
        Level(name: "Village", population: "Hundreds", services: "A shop, primary school or place of worship may serve the area.", buildings: 6, symbol: "house.lodge.fill"),
        Level(name: "Small town", population: "Thousands", services: "More shops, schools and local transport become available.", buildings: 10, symbol: "building.2.fill"),
        Level(name: "Large town", population: "Tens of thousands", services: "Residents can use hospitals, larger shops and more transport links.", buildings: 14, symbol: "building.2.fill"),
        Level(name: "City", population: "Hundreds of thousands", services: "Universities, specialist healthcare and major business districts serve a wide area.", buildings: 18, symbol: "building.columns.fill"),
        Level(name: "Conurbation", population: "Millions", services: "Several urban areas join to form one continuous built-up area.", buildings: 22, symbol: "building.2.crop.circle.fill")
    ]

    @State private var position = 0.0

    private var selectedIndex: Int { Int(position.rounded()) }
    private var selected: Level { levels[selectedIndex] }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Move the slider and watch the settlement grow.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                SettlementScene(level: selectedIndex, buildingCount: selected.buildings)
                    .frame(height: 330)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: .black.opacity(0.14), radius: 10, y: 5)

                VStack(spacing: 8) {
                    Slider(value: $position, in: 0...Double(levels.count - 1), step: 1)
                        .tint(.teal)
                    HStack {
                        Text("One home")
                        Spacer()
                        Text("Conurbation")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                QuizCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label(selected.name, systemImage: selected.symbol)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.teal)
                        Label(selected.population, systemImage: "person.3.fill")
                            .font(.subheadline.weight(.semibold))
                        Text(selected.services)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(20)
        }
        .background(AnimatedOceanBackground())
        .navigationTitle("Settlement hierarchy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct SettlementScene: View {
    let level: Int
    let buildingCount: Int

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.55, green: 0.84, blue: 1), Color(red: 0.91, green: 0.97, blue: 1)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                Circle()
                    .fill(.yellow.opacity(0.9))
                    .frame(width: 48, height: 48)
                    .position(x: geometry.size.width * 0.82, y: 55)

                Rectangle()
                    .fill(Color(red: 0.34, green: 0.68, blue: 0.31))
                    .frame(height: 105)
                    .frame(maxHeight: .infinity, alignment: .bottom)

                if level >= 3 {
                    Rectangle()
                        .fill(.gray.opacity(0.75))
                        .frame(height: 28)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .fill(.white.opacity(0.8))
                                .frame(height: 2)
                                .padding(.bottom, 13)
                        }
                }

                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: level >= 4 ? 6 : 4),
                    spacing: 5
                ) {
                    ForEach(0..<buildingCount, id: \.self) { index in
                        Image(systemName: level >= 4 && index.isMultiple(of: 3) ? "building.2.fill" : "house.fill")
                            .font(.system(size: level >= 4 ? 28 : 32))
                            .foregroundStyle(index.isMultiple(of: 2) ? .orange : AppPalette.navy)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, level >= 3 ? 48 : 22)
                .frame(maxHeight: .infinity, alignment: .bottom)

                CatCharacter(accessory: level >= 3 ? "briefcase.fill" : "leaf.fill", tint: .teal)
                    .frame(width: 72, height: 78)
                    .position(x: 54, y: geometry.size.height - 48)
            }
        }
        .animation(.snappy, value: level)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Settlement with \(buildingCount) buildings")
    }
}

struct MangroveRootsView: View {
    private enum RootType: String, CaseIterable, Identifiable {
        case prop = "Prop roots"
        case pneumatophore = "Breathing roots"
        case knee = "Knee roots"

        var id: Self { self }

        var detail: String {
            switch self {
            case .prop: return "Arching roots spread the tree's weight and hold it upright in soft mud."
            case .pneumatophore: return "Pencil-shaped roots grow above the waterlogged soil and take in oxygen through small pores."
            case .knee: return "Sections of root rise above the mud like knees. They help with gas exchange and stability."
            }
        }

        var prompt: String {
            switch self {
            case .prop: return "Tap the wide roots"
            case .pneumatophore: return "Tap the roots pointing up"
            case .knee: return "Tap a loop in the mud"
            }
        }
    }

    @State private var selection = RootType.prop
    @State private var pulse = false

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Picker("Root type", selection: $selection) {
                    ForEach(RootType.allCases) { root in
                        Text(root.rawValue).tag(root)
                    }
                }
                .pickerStyle(.segmented)

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.55)) {
                        pulse.toggle()
                    }
                } label: {
                    MangroveScene(rootType: selection.rawValue, pulse: pulse)
                        .frame(height: 380)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(selection.prompt)

                QuizCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(selection.prompt)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.green)
                        Text(selection.rawValue)
                            .font(.title3.weight(.bold))
                        Text(selection.detail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(20)
        }
        .background(AnimatedOceanBackground())
        .navigationTitle("Mangrove roots")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct MangroveScene: View {
    let rootType: String
    let pulse: Bool

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.58, green: 0.87, blue: 0.96), Color(red: 0.75, green: 0.91, blue: 0.86)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                Rectangle()
                    .fill(Color(red: 0.30, green: 0.68, blue: 0.75).opacity(0.7))
                    .frame(height: 95)
                    .position(x: width / 2, y: height - 70)
                Rectangle()
                    .fill(Color(red: 0.39, green: 0.27, blue: 0.17))
                    .frame(height: 55)
                    .frame(maxHeight: .infinity, alignment: .bottom)

                Capsule()
                    .fill(Color(red: 0.36, green: 0.22, blue: 0.12))
                    .frame(width: 28, height: 185)
                    .position(x: width / 2, y: 183)

                Image(systemName: "tree.fill")
                    .font(.system(size: 170))
                    .foregroundStyle(Color(red: 0.10, green: 0.46, blue: 0.22))
                    .position(x: width / 2, y: 105)

                roots(width: width, height: height)
                    .foregroundStyle(.brown)
                    .scaleEffect(pulse ? 1.06 : 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.14), radius: 10, y: 5)
        }
    }

    @ViewBuilder
    private func roots(width: CGFloat, height: CGFloat) -> some View {
        if rootType == "Prop roots" {
            ForEach(0..<7, id: \.self) { index in
                Path { path in
                    let offset = CGFloat(index - 3) * 24
                    path.move(to: CGPoint(x: width / 2, y: height * 0.50))
                    path.addQuadCurve(
                        to: CGPoint(x: width / 2 + offset, y: height - 22),
                        control: CGPoint(x: width / 2 + offset * 0.8, y: height * 0.68)
                    )
                }
                .stroke(.brown, style: StrokeStyle(lineWidth: 9, lineCap: .round))
            }
        } else if rootType == "Breathing roots" {
            ForEach(0..<15, id: \.self) { index in
                Capsule()
                    .frame(width: 7, height: CGFloat(24 + index % 3 * 10))
                    .position(x: 24 + CGFloat(index) * (width - 48) / 14, y: height - 45)
            }
        } else {
            ForEach(0..<6, id: \.self) { index in
                Path { path in
                    let start = 30 + CGFloat(index) * (width - 60) / 6
                    path.move(to: CGPoint(x: start, y: height - 24))
                    path.addQuadCurve(
                        to: CGPoint(x: start + 42, y: height - 24),
                        control: CGPoint(x: start + 21, y: height - 82)
                    )
                }
                .stroke(.brown, style: StrokeStyle(lineWidth: 8, lineCap: .round))
            }
        }
    }
}

struct HousingSolutionsView: View {
    @State private var progress = 0.0

    private var solutionCount: Int {
        min(4, Int((progress * 5).rounded(.down)))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Move the slider to improve the neighbourhood.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HousingScene(solutionCount: solutionCount)
                    .frame(height: 390)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: .black.opacity(0.14), radius: 10, y: 5)

                VStack(spacing: 8) {
                    Slider(value: $progress, in: 0...1)
                        .tint(.orange)
                    HStack {
                        Text("Housing problems")
                        Spacer()
                        Text("Sustainable community")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                QuizCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(solutionCount == 4 ? "The neighbourhood is ready" : "Add the next improvement")
                            .font(.headline)
                        if solutionCount == 0 {
                            Text(improvements[0])
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(Array(improvements.prefix(solutionCount).enumerated()), id: \.offset) { _, improvement in
                                Label(improvement, systemImage: "checkmark.circle.fill")
                                    .font(.subheadline)
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(AnimatedOceanBackground())
        .navigationTitle("Sustainable housing")
        .navigationBarTitleDisplayMode(.inline)
    }

    private let improvements = [
        "Safe waste and sewage disposal",
        "Reliable public transport",
        "Parks and shared spaces",
        "Solar power and rainwater collection"
    ]
}

private struct HousingScene: View {
    let solutionCount: Int

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.67, green: 0.86, blue: 1), Color(red: 0.96, green: 0.96, blue: 0.86)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                Rectangle()
                    .fill(solutionCount >= 3 ? Color.green.opacity(0.55) : Color.brown.opacity(0.42))
                    .frame(height: 110)
                    .frame(maxHeight: .infinity, alignment: .bottom)

                HStack(alignment: .bottom, spacing: 9) {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 50 + CGFloat(index % 2) * 18))
                            .foregroundStyle(index.isMultiple(of: 2) ? AppPalette.navy : .orange)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 70)

                if solutionCount >= 1 {
                    Label("Clean water", systemImage: "drop.fill")
                        .sceneChip(color: .blue)
                        .position(x: 78, y: 58)
                }
                if solutionCount >= 2 {
                    Label("Bus link", systemImage: "bus.fill")
                        .sceneChip(color: .purple)
                        .position(x: geometry.size.width - 70, y: 85)
                }
                if solutionCount >= 3 {
                    Image(systemName: "tree.fill")
                        .font(.system(size: 62))
                        .foregroundStyle(.green)
                        .position(x: 64, y: geometry.size.height - 77)
                }
                if solutionCount >= 4 {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 42))
                        .foregroundStyle(.yellow)
                        .position(x: geometry.size.width - 58, y: 48)
                }

                CatCharacter(accessory: solutionCount >= 2 ? "heart.fill" : "exclamationmark.triangle.fill", tint: solutionCount >= 2 ? .green : .orange)
                    .frame(width: 84, height: 90)
                    .position(x: geometry.size.width / 2, y: geometry.size.height - 44)
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.72), value: solutionCount)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Neighbourhood with \(solutionCount) of 4 improvements")
    }
}

struct CatCharacter: View {
    let accessory: String
    let tint: Color

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            ZStack {
                Triangle()
                    .fill(Color(red: 0.95, green: 0.76, blue: 0.48))
                    .frame(width: size * 0.30, height: size * 0.30)
                    .rotationEffect(.degrees(-18))
                    .offset(x: -size * 0.24, y: -size * 0.29)
                Triangle()
                    .fill(Color(red: 0.95, green: 0.76, blue: 0.48))
                    .frame(width: size * 0.30, height: size * 0.30)
                    .rotationEffect(.degrees(18))
                    .offset(x: size * 0.24, y: -size * 0.29)

                Circle()
                    .fill(Color(red: 0.95, green: 0.76, blue: 0.48))
                    .overlay {
                        VStack(spacing: size * 0.06) {
                            HStack(spacing: size * 0.19) {
                                Circle().frame(width: size * 0.06, height: size * 0.06)
                                Circle().frame(width: size * 0.06, height: size * 0.06)
                            }
                            Text("ω")
                                .font(.system(size: size * 0.19, weight: .medium, design: .rounded))
                        }
                        .foregroundStyle(AppPalette.navy)
                    }
                    .padding(size * 0.08)

                Image(systemName: accessory)
                    .font(.system(size: size * 0.20, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(size * 0.09)
                    .background(Circle().fill(tint))
                    .offset(x: size * 0.34, y: size * 0.31)
            }
        }
        .accessibilityHidden(true)
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

private extension View {
    func sceneChip(color: Color) -> some View {
        font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(color))
    }
}

#Preview("Settlements") {
    NavigationStack { SettlementHierarchyView() }
}

#Preview("Mangroves") {
    NavigationStack { MangroveRootsView() }
}

#Preview("Housing") {
    NavigationStack { HousingSolutionsView() }
}
