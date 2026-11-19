import SwiftUI

// MARK: - 2. Mangrove Roots

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

#Preview("Mangroves") {
    NavigationStack { MangroveRootsView() }
}
