import SwiftUI

private enum AdventureDestination: String, CaseIterable, Identifiable, Hashable {
    case simulations = "Simulations"
    case geogWorld = "GeogWorld"
    case quizzes = "Quizzes"

    var id: Self { self }

    var subtitle: String {
        switch self {
        case .simulations:
            return "Explore geography through interactive models"
        case .geogWorld:
            return "Travel the world, meet characters and complete quests"
        case .quizzes:
            return "Test what you know and track your best scores"
        }
    }

    var symbol: String {
        switch self {
        case .simulations: return "sparkles.rectangle.stack.fill"
        case .geogWorld: return "gamecontroller.fill"
        case .quizzes: return "questionmark.bubble.fill"
        }
    }

    var tint: Color {
        switch self {
        case .simulations: return AppPalette.blue
        case .geogWorld: return .indigo
        case .quizzes: return .teal
        }
    }
}

struct TopicListView: View {
    var onBack: (() -> Void)?

    init(onBack: (() -> Void)? = nil) {
        self.onBack = onBack
    }

    var body: some View {
        NavigationStack {
            AdventureHubView()
                .toolbar {
                    if let onBack {
                        ToolbarItem(placement: .topBarLeading) {
                            Button(action: onBack) {
                                Label("Back", systemImage: "chevron.left")
                            }
                        }
                    }
                }
                .navigationDestination(for: AdventureDestination.self) { destination in
                    switch destination {
                    case .simulations:
                        SimulationCatalogView()
                    case .geogWorld:
                        GeoWorldView()
                    case .quizzes:
                        QuizCatalogView()
                    }
                }
                .navigationDestination(for: QuizTopic.self) { topic in
                    QuizView(topic: topic)
                }
                .navigationDestination(for: SimulationDestination.self) { destination in
                    destination.view
                }
        }
    }
}

private struct AdventureHubView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Choose your adventure")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(AppPalette.navy)

                    Text("Pick a way to explore geography.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                ForEach(AdventureDestination.allCases) { destination in
                    NavigationLink(value: destination) {
                        AdventureCard(destination: destination)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
        .background(AnimatedOceanBackground())
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AdventureCard: View {
    let destination: AdventureDestination

    var body: some View {
        HStack(spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(destination.tint.opacity(0.16))

                Image(systemName: destination.symbol)
                    .font(.system(size: 29, weight: .semibold))
                    .foregroundStyle(destination.tint)
            }
            .frame(width: 68, height: 68)

            VStack(alignment: .leading, spacing: 6) {
                Text(destination.rawValue)
                    .font(.title3.bold())
                    .foregroundStyle(.primary)

                Text(destination.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 4)

            Image(systemName: "chevron.right.circle.fill")
                .font(.title2)
                .foregroundStyle(destination.tint)
        }
        .padding(19)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .shadow(color: .black.opacity(0.06), radius: 16, y: 7)
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens \(destination.rawValue)")
    }
}

private struct SimulationCatalogView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                ForEach(SimulationDestination.allCases.filter { $0 != .geoWorld }) { destination in
                    NavigationLink(value: destination) {
                        SimulationCard(destination: destination)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
        }
        .background(AnimatedOceanBackground())
        .navigationTitle("Simulations")
        .navigationBarTitleDisplayMode(.large)
    }
}

private struct QuizCatalogView: View {
    @EnvironmentObject private var progress: ProgressStore

    private var topics: [QuizTopic] { QuestionBank.topics }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                ForEach(topics) { topic in
                    NavigationLink(value: topic) {
                        TopicCard(topic: topic, record: progress.records[topic.id])
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
        }
        .background(AnimatedOceanBackground())
        .navigationTitle("Quizzes")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    TopicListView()
        .environmentObject(ProgressStore())
}
