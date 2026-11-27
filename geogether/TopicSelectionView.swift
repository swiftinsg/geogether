import SwiftUI

struct TopicSelectionView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            MovingBlueBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    Text("Choose your topic")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.25), radius: 8, y: 3)
                        .padding(16)
                        .accessibilityAddTraits(.isHeader)

                    VStack(spacing: 20) {
                        TopicCard(
                            title: "Sustainable Housing",
                            symbol: "house.fill",
                            color: Color(red: 0.14, green: 0.55, blue: 0.38),
                            isSustainableHousing: true
                        )
                        TopicCard(
                            title: "Mangroves and Rainforests",
                            symbol: "tree.fill",
                            color: Color(red: 0.04, green: 0.51, blue: 0.53),
                            isMangrovesAndRainforests: true
                        )
                        TopicCard(
                            title: "Settlements",
                            symbol: "building.2.fill",
                            color: Color(red: 0.19, green: 0.43, blue: 0.76)
                        )
                    }
                }
                .padding(24)
                .frame(maxWidth: 600, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
        }
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
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct TopicCard: View {
    let title: LocalizedStringKey
    let symbol: String
    let color: Color
    var isSustainableHousing = false
    var isMangrovesAndRainforests = false

    var body: some View {
        NavigationLink {
            if isSustainableHousing {
                SustainableHousingView()
            } else if isMangrovesAndRainforests {
                MangrovesAndRainforestsView()
            } else {
                TopicDetailView(title: title, symbol: symbol)
            }
        } label: {
            HStack(spacing: 16) {
                Image(systemName: symbol)
                    .font(.system(.title, weight: .semibold))
                    .frame(width: 56, height: 56)
                    .background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 16))
                    .accessibilityHidden(true)

                Text(title)
                    .font(.title2.bold())
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "arrow.right")
                    .font(.title3.weight(.semibold))
                    .accessibilityHidden(true)
            }
            .foregroundStyle(.white)
            .padding(22)
            .frame(maxWidth: .infinity, minHeight: 136)
            .background {
                MovingTopicGradient(color: color)
            }
            .clipShape(RoundedRectangle(cornerRadius: 26))
            .overlay {
                RoundedRectangle(cornerRadius: 26)
                    .strokeBorder(.white.opacity(0.3), lineWidth: 1)
            }
            .shadow(color: color.opacity(0.24), radius: 12, y: 7)
            .contentShape(RoundedRectangle(cornerRadius: 26))
        }
        .buttonStyle(.plain)
    }
}

private struct MovingTopicGradient: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let color: Color

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30, paused: reduceMotion)) { context in
            let time = reduceMotion ? 0 : context.date.timeIntervalSinceReferenceDate
            let drift = (sin(time * 0.35) + 1) / 2

            // Move light, normal, and dark shades slowly across each card.
            LinearGradient(
                colors: [
                    color.mix(with: .white, by: 0.26),
                    color,
                    color.mix(with: .black, by: 0.38)
                ],
                startPoint: UnitPoint(x: -0.5 + drift, y: 0),
                endPoint: UnitPoint(x: 0.5 + drift, y: 1)
            )
            .overlay(.black.opacity(0.16))
        }
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }
}

#Preview {
    NavigationStack {
        TopicSelectionView()
    }
}
