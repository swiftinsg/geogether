import SwiftUI

// MARK: - 1. Settlement Hierarchy

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
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(.white.opacity(0.6), lineWidth: 1)
                    )
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

#Preview("Settlements") {
    NavigationStack { SettlementHierarchyView() }
}
