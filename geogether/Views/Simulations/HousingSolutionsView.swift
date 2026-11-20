import SwiftUI

// MARK: 3. Sustainable housing

struct HousingSolutionsView: View {
    @State private var progress = 0.0

    private var solutionCount: Int {
        min(4, Int((progress * 5).rounded(.down)))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Move the slider to add each improvement.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HousingScene(solutionCount: solutionCount)
                    .frame(height: 390)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(.white.opacity(0.6), lineWidth: 1)
                    )
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
                        Text(solutionCount == 4 ? "All four improvements are in place" : "Next improvement")
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

#Preview("Housing") {
    NavigationStack { HousingSolutionsView() }
}
