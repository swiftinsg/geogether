import SwiftUI

/// Drag-to-compare lesson adapted from the urban and rural prototype.
struct HousingCompareView: View {
    @State private var split = 0.5

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Drag the divider to compare the two environments.")
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
        .background(AnimatedOceanBackground())
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

private struct UrbanScene: View {
    private let heights = [0.45, 0.65, 0.38, 0.72, 0.55, 0.62, 0.42]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.70, green: 0.78, blue: 0.90), Color(red: 0.90, green: 0.92, blue: 0.95)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                HStack(alignment: .bottom, spacing: 5) {
                    ForEach(Array(heights.enumerated()), id: \.offset) { _, height in
                        ZStack {
                            Rectangle().fill(Color(red: 0.35, green: 0.42, blue: 0.55))
                            VStack(spacing: 6) {
                                ForEach(0..<6, id: \.self) { _ in
                                    HStack(spacing: 5) {
                                        ForEach(0..<3, id: \.self) { _ in
                                            Rectangle()
                                                .fill(.yellow.opacity(0.85))
                                                .frame(width: 6, height: 8)
                                        }
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }
                        .frame(height: geometry.size.height * height)
                    }
                }
                .padding(.horizontal, 8)
                .frame(maxHeight: .infinity, alignment: .bottom)

                Rectangle()
                    .fill(Color(red: 0.25, green: 0.27, blue: 0.30))
                    .frame(height: 22)
                    .frame(maxHeight: .infinity, alignment: .bottom)

                CatCharacter(accessory: "briefcase.fill", tint: .purple)
                    .frame(width: 72, height: 76)
                    .position(x: geometry.size.width * 0.72, y: geometry.size.height - 42)
            }
        }
    }
}

private struct RuralScene: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.55, green: 0.80, blue: 0.98), Color(red: 0.90, green: 0.97, blue: 1)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                Circle()
                    .fill(.yellow)
                    .frame(width: 54, height: 54)
                    .position(x: geometry.size.width * 0.78, y: geometry.size.height * 0.16)

                Ellipse()
                    .fill(Color(red: 0.45, green: 0.75, blue: 0.40))
                    .frame(width: geometry.size.width * 1.2, height: geometry.size.height * 0.55)
                    .position(x: geometry.size.width * 0.25, y: geometry.size.height * 0.95)
                Ellipse()
                    .fill(Color(red: 0.30, green: 0.65, blue: 0.32))
                    .frame(width: geometry.size.width * 1.2, height: geometry.size.height * 0.5)
                    .position(x: geometry.size.width * 0.80, y: geometry.size.height)

                Image(systemName: "house.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color(red: 0.75, green: 0.35, blue: 0.25))
                    .position(x: geometry.size.width * 0.30, y: geometry.size.height * 0.66)
                Image(systemName: "house.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color(red: 0.55, green: 0.40, blue: 0.30))
                    .position(x: geometry.size.width * 0.58, y: geometry.size.height * 0.74)
                Image(systemName: "tree.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(Color(red: 0.10, green: 0.50, blue: 0.20))
                    .position(x: geometry.size.width * 0.14, y: geometry.size.height * 0.70)
                Image(systemName: "tree.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Color(red: 0.10, green: 0.50, blue: 0.20))
                    .position(x: geometry.size.width * 0.82, y: geometry.size.height * 0.78)

                CatCharacter(accessory: "leaf.fill", tint: .green)
                    .frame(width: 72, height: 76)
                    .position(x: geometry.size.width * 0.70, y: geometry.size.height - 42)
            }
        }
    }
}

#Preview {
    NavigationStack { HousingCompareView() }
}
