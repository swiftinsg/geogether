import SwiftUI

struct GameSimulationPickerView: View {
    @Environment(\.dismiss) private var dismiss

    private let simulations = SimulationDestination.allCases.filter { $0 != .geoWorld }

    var body: some View {
        NavigationStack {
            List(simulations) { destination in
                NavigationLink {
                    GameSimulationHostView(destination: destination)
                } label: {
                    Label {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(destination.title)
                                .font(.headline)
                            Text(destination.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: destination.symbol)
                            .foregroundStyle(destination.tint)
                    }
                }
            }
            .navigationTitle("Simulations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .tint(.blue)
    }
}

struct GameSimulationHostView: View {
    let destination: SimulationDestination

    var body: some View {
        destination.view
            .navigationTitle(destination.title)
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct GameSimulationSheet: View {
    @Environment(\.dismiss) private var dismiss

    let destination: SimulationDestination

    var body: some View {
        NavigationStack {
            GameSimulationHostView(destination: destination)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
        .tint(.blue)
    }
}

extension GeoQuest {
    var relatedSimulation: SimulationDestination? {
        switch id {
        case "patterns", "hierarchy", "migration":
            return .settlements
        case "services", "rural_urban", "microclimate":
            return .urbanRural
        case "mangroves":
            return .mangroveRoots
        case "housing", "food_miles":
            return .housing
        default:
            return nil
        }
    }
}
