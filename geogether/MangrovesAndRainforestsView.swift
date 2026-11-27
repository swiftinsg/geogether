import SwiftUI

struct MangrovesAndRainforestsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPage = 0

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedPage) {
                MangroveLessonView()
                    .tag(0)
                RainforestLessonView()
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            HStack {
                Button("Previous", systemImage: "globe.badge.chevron.backward") {
                    selectedPage = 0
                }
                .disabled(selectedPage == 0)

                Spacer(minLength: 8)

                Text(selectedPage == 0 ? "Mangroves · 1 of 2" : "Rainforest · 2 of 2")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)

                Spacer(minLength: 8)

                Button("Next", systemImage: "chevron.right") {
                    selectedPage = 1
                }
                .disabled(selectedPage == 1)
            }
            .padding()
            .background(.background)
        }
        .background(.green.opacity(0.07))
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "globe.badge.chevron.backward")
                        .font(.body)
                }
                .accessibilityLabel("Back")
            }
        }
        .navigationTitle("Mangroves and Rainforests")
        .navigationBarTitleDisplayMode(.inline)
        .tint(Color(red: 0.12, green: 0.42, blue: 0.29))
    }
}

private struct MangroveLessonView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Mangroves")
                    .font(.largeTitle.bold())
                    .accessibilityAddTraits(.isHeader)

                ForestLessonCard(title: "Learning objectives") {
                    Text("1. Describe the characteristics of mangroves.")
                    Text("2. Describe how mangroves adapt to their environment.")
                }

                ForestLessonCard(title: "Characteristics of mangroves") {
                    Text("Mangrove plants are evergreen: they keep their leaves throughout the year.")
                    Text("They have a much lower diversity of plant species than tropical rainforests.")
                    Text("There are about 60–70 mangrove tree species worldwide.")
                }

                MangroveTideStudy()

                ForestLessonCard(title: "Adaptations to salty water") {
                    Label("Salt-secreting leaves", systemImage: "leaf.fill")
                        .font(.headline)
                    Text("Some mangroves release excess salt through special glands on their leaves.")
                    Label("Salt-excluding roots", systemImage: "drop.fill")
                        .font(.headline)
                    Text("Some mangroves filter out much of the salt at their roots as they take in water.")
                }

                MangroveRootStudy()



            }
            .padding(24)
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        .background(.green.opacity(0.07))
    }
}

private struct RainforestLessonView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Rainforest")
                    .font(.largeTitle.bold())
                    .accessibilityAddTraits(.isHeader)

                ForestLessonCard(title: "Learning objective") {
                    Text("Name the different layers of a rainforest.")
                }

                ForestLessonCard(title: "Layers of a tropical rainforest") {
                    Text("Emergent layer · High · 30 m and above")
                    Text("Canopy layer · Middle · 20–30 m")
                    Text("Undergrowth layer · Low · 0–20 m")
                }

                RainforestSimulationView()
            }
            .padding(24)
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
    }
}

private struct ForestLessonCard<Content: View>: View {
    let title: LocalizedStringKey
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.title2.bold())
                .accessibilityAddTraits(.isHeader)
            content
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 24))
    }
}

private struct MangroveTideStudy: View {
    @State private var highTide = false

    var body: some View {
        ForestLessonCard(title: "Low tide and high tide") {
            Text("Change the tide to see how the water level around the roots changes.")
            Picker("Tide level", selection: $highTide) {
                Text("Low tide").tag(false)
                Text("High tide").tag(true)
            }
            .pickerStyle(.segmented)

            Image("MangrovePropRoots")
                .resizable()
                .scaledToFit()
                .overlay {
                    GeometryReader { geometry in
                        // Proportional levels keep the water aligned as the artwork resizes.
                        Rectangle()
                            .fill(.blue.opacity(0.4))
                            .frame(height: geometry.size.height * (highTide ? 0.625 : 0.196))
                            .overlay(alignment: .top) {
                                Rectangle()
                                    .fill(.blue)
                                    .frame(height: 3)
                            }
                            .frame(maxHeight: .infinity, alignment: .bottom)
                    }
                    .allowsHitTesting(false)
                }
            .frame(maxWidth: 280)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(highTide
                ? "High tide: seawater covers more of the mangrove roots."
                : "Low tide: the water recedes, exposing more roots to air.")

            Text(highTide
                 ? "At high tide, seawater rises and covers more of the roots and muddy ground."
                 : "At low tide, seawater recedes and more roots are exposed to the air.")
            Text("Mangroves grow in coastal areas where water levels rise and fall with the tides.")
                .foregroundStyle(.secondary)
        }
    }
}

private enum MangroveRoot: CaseIterable, Identifiable {
    case pencil, cone, prop, knee

    var id: Self { self }

    var title: LocalizedStringResource {
        switch self {
        case .pencil: "Pencil roots"
        case .cone: "Cone roots"
        case .prop: "Prop roots"
        case .knee: "Knee-bend roots"
        }
    }

    var artwork: String {
        switch self {
        case .pencil: "MangroveBreathingRoots"
        case .cone: "MangroveConeRoots"
        case .prop: "MangrovePropRoots"
        case .knee: "MangroveKneeRoots"
        }
    }

    var detail: LocalizedStringResource {
        switch self {
        case .pencil: "Slender, upright breathing roots project above the mud and take in oxygen when exposed to air."
        case .cone: "Cone-shaped breathing roots rise above the mud, helping the tree obtain oxygen in waterlogged soil."
        case .prop: "Arching roots extend from the trunk into the mud. They support the tree in soft soil and also help it obtain oxygen."
        case .knee: "Roots bend upwards out of the mud and loop down again, like bent knees, helping the tree obtain oxygen."
        }
    }
}

private struct MangroveRootStudy: View {
    @State private var selectedRoot: MangroveRoot = .pencil

    var body: some View {
        ForestLessonCard(title: "Aerial roots") {
            Text("Waterlogged mud contains little oxygen. Different mangroves have different root adaptations for obtaining air and support.")
            Picker("Root type", selection: $selectedRoot) {
                ForEach(MangroveRoot.allCases) { root in
                    Text(root.title).tag(root)
                }
            }
            .pickerStyle(.menu)

            Image(selectedRoot.artwork)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 320)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .frame(maxWidth: .infinity)
                .accessibilityLabel(selectedRoot.title)
            Text(selectedRoot.title)
                .font(.headline)
            Text(selectedRoot.detail)
            if selectedRoot == .pencil || selectedRoot == .cone {
                Text("Pencil roots are slender, while cone roots have a wider base.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private enum RainforestLayer: CaseIterable, Identifiable {
    case undergrowth, canopy, emergent

    var id: Self { self }

    var title: LocalizedStringResource {
        switch self {
        case .undergrowth: "Undergrowth"
        case .canopy: "Canopy"
        case .emergent: "Emergent"
        }
    }

    var height: LocalizedStringResource {
        switch self {
        case .undergrowth: "0–20 metres"
        case .canopy: "20–30 metres"
        case .emergent: "30 metres and above"
        }
    }

    var sunlight: LocalizedStringResource {
        switch self {
        case .undergrowth: "Very little sunlight"
        case .canopy: "Blocks about 97–98% of sunlight from reaching the undergrowth"
        case .emergent: "Receives the most sunlight"
        }
    }

    var detail: LocalizedStringResource {
        switch self {
        case .undergrowth:
            "Barely any sunlight reaches this layer. Few plants can grow here, except smaller plants that need less sunlight."
        case .canopy:
            "Trees are crowded together. Their branches and leaves interlock to form a canopy that shades the undergrowth."
        case .emergent:
            "These are the tallest trees in the tropical rainforest. They rise above the canopy and can absorb the most sunlight."
        }
    }

    // Schematic artwork regions, rather than a measured height scale.
    var band: (top: CGFloat, height: CGFloat) {
        switch self {
        case .undergrowth: (0.72, 0.28)
        case .canopy: (0.28, 0.44)
        case .emergent: (0, 0.28)
        }
    }
}

struct RainforestSimulationView: View {
    @State private var layerPosition = 0.0

    private var selectedLayer: RainforestLayer {
        switch layerPosition {
        case ..<0.5: .undergrowth
        case ..<1.5: .canopy
        default: .emergent
        }
    }

    var body: some View {
        ForestLessonCard(title: "Explore the rainforest") {
            Text("Drag the slider up to climb through the rainforest, or down to return to the forest floor.")

            HStack(alignment: .center, spacing: 12) {
                RainforestLayerArtwork(layer: selectedLayer)
                    .frame(maxWidth: .infinity)

                RainforestVerticalSlider(position: $layerPosition, layer: selectedLayer)
            }

            Text(selectedLayer.title)
                .font(.title.bold())
                .accessibilityAddTraits(.isHeader)
            Label {
                Text(selectedLayer.height)
            } icon: {
                Image(systemName: "arrow.up.and.down")
            }
            .font(.headline)
            Label {
                Text(selectedLayer.sunlight)
            } icon: {
                Image(systemName: "sun.max.fill")
            }
            Text(selectedLayer.detail)
        }
    }
}

private struct RainforestVerticalSlider: View {
    @Binding var position: Double
    let layer: RainforestLayer

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "sun.max.fill")
                .accessibilityHidden(true)

            // Rotating the native slider keeps its adjustable accessibility behavior.
            // A second frame reserves the rotated dimensions in the surrounding layout.
            Slider(value: $position, in: 0...2, step: 1) {
                Text("Rainforest layer")
            }
            .frame(width: 220, height: 44)
            .rotationEffect(.degrees(-90))
            .frame(width: 44, height: 220)
            .environment(\.layoutDirection, .leftToRight)
            .accessibilityValue(Text(layer.title))
            .accessibilityHint("Adjust upwards for higher layers and downwards for lower layers.")

            Image(systemName: "leaf.fill")
                .accessibilityHidden(true)
        }
    }
}

private struct RainforestLayerArtwork: View {
    let layer: RainforestLayer

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image("RainforestLayers")
                .resizable()
                .scaledToFit()
                .overlay {
                    GeometryReader { geometry in
                        let top = geometry.size.height * layer.band.top
                        let height = geometry.size.height * layer.band.height

                        Color.black.opacity(0.42)
                            .frame(height: top)
                        Color.black.opacity(0.42)
                            .frame(height: geometry.size.height - top - height)
                            .offset(y: top + height)
                        Rectangle()
                            .strokeBorder(.yellow, lineWidth: 4)
                            .frame(height: height)
                            .offset(y: top)
                    }
                    .allowsHitTesting(false)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .accessibilityLabel("Rainforest illustration highlighting the selected layer.")
                .accessibilityValue(Text(layer.title))
            Text("Highlighted regions are schematic; the illustration is not to scale.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        MangrovesAndRainforestsView()
    }
}

#Preview("Rainforest simulation") {
    NavigationStack {
        RainforestSimulationView()
    }
}
