import SwiftUI

/// Comparison adapted from the urban and rural prototype.
struct HousingCompareView: View {
    @Environment(\.isEmbeddedSimulation) private var isEmbeddedSimulation
    @State private var split = 0.5

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Drag the divider to compare urban and rural areas.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                GeometryReader { geometry in
                    let handleX = geometry.size.width * split

                    ZStack {
                        RuralScene()
                        UrbanScene()
                            .mask(alignment: .leading) {
                                Rectangle().frame(width: handleX)
                            }

                        Rectangle()
                            .fill(.white)
                            .frame(width: 3)
                            .shadow(color: .black.opacity(0.3), radius: 3)
                            .position(x: handleX, y: geometry.size.height / 2)

                        Image(systemName: "arrow.left.and.right")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(AppPalette.blue)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(.white))
                            .shadow(color: .black.opacity(0.3), radius: 4)
                            .position(x: handleX, y: geometry.size.height / 2)

                        sceneLabel("URBAN", x: 48)
                        sceneLabel("RURAL", x: geometry.size.width - 48)
                    }
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                split = min(max(value.location.x / geometry.size.width, 0.08), 0.92)
                            }
                    )
                }
                .frame(height: 400)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Urban and rural housing comparison")
                .accessibilityValue("\(Int(split * 100)) percent urban")
                .accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment: split = min(split + 0.1, 0.92)
                    case .decrement: split = max(split - 0.1, 0.08)
                    @unknown default: break
                    }
                }

                HStack(spacing: 10) {
                    Text("Urban")
                        .foregroundStyle(AppPalette.navy)
                    Slider(value: $split, in: 0.08...0.92)
                    Text("Rural")
                        .foregroundStyle(.green)
                }
                .font(.subheadline.weight(.semibold))

                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .top, spacing: 12) { comparisonCards }
                    VStack(spacing: 12) { comparisonCards }
                }
            }
            .padding(20)
        }
        .background {
            if !isEmbeddedSimulation {
                AnimatedOceanBackground()
            }
        }
        .navigationTitle("Urban and rural housing")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var comparisonCards: some View {
        comparisonCard(
            title: "Urban",
            symbol: "building.2.fill",
            tint: AppPalette.navy,
            text: "More jobs and specialised services, including universities and major hospitals."
        )
        comparisonCard(
            title: "Rural",
            symbol: "leaf.fill",
            tint: .green,
            text: "More open land and local services such as primary schools, clinics and small shops."
        )
    }

    private func comparisonCard(title: String, symbol: String, tint: Color, text: String) -> some View {
        QuizCard {
            VStack(alignment: .leading, spacing: 8) {
                Label(title, systemImage: symbol)
                    .font(.headline)
                    .foregroundStyle(tint)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func sceneLabel(_ text: String, x: CGFloat) -> some View {
        Text(text)
            .font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(.black.opacity(0.45)))
            .position(x: x, y: 26)
    }
}

#Preview {
    NavigationStack { HousingCompareView() }
}
