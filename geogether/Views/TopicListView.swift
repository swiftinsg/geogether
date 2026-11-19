import SwiftUI

struct TopicListView: View {
    private enum Section: String, CaseIterable, Identifiable {
        case simulations = "Simulations"
        case quizzes = "Quizzes"

        var id: Self { self }
    }

    @EnvironmentObject private var progress: ProgressStore
    @State private var section = Section.simulations
    var onBack: (() -> Void)?

    init(onBack: (() -> Void)? = nil) {
        self.onBack = onBack
    }

    private var topics: [QuizTopic] { QuestionBank.topics }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Text("Choose your next challenge")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(AppPalette.navy)

                    Picker("Learning mode", selection: $section) {
                        ForEach(Section.allCases) { section in
                            Text(section.rawValue).tag(section)
                        }
                    }
                    .pickerStyle(.segmented)

                    if section == .simulations {
                        simulationList
                    } else {
                        quizList
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .background(AnimatedOceanBackground())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if let onBack {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: onBack) {
                            Label("Back", systemImage: "chevron.left")
                        }
                    }
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

    private var simulationList: some View {
        VStack(spacing: 14) {
            ForEach(SimulationDestination.allCases) { destination in
                NavigationLink(value: destination) {
                    SimulationCard(destination: destination)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var quizList: some View {
        VStack(spacing: 14) {
            ForEach(topics) { topic in
                NavigationLink(value: topic) {
                    TopicCard(topic: topic, record: progress.records[topic.id])
                }
                .buttonStyle(.plain)
            }
        }
    }
}

enum SimulationDestination: String, CaseIterable, Identifiable, Hashable {
    case urbanRural
    case waterCycle
    case settlements
    case mangroveRoots
    case housing

    var id: Self { self }

    var title: String {
        switch self {
        case .urbanRural: return "Urban and rural"
        case .waterCycle: return "Water distribution"
        case .settlements: return "Settlement hierarchy"
        case .mangroveRoots: return "Mangrove roots"
        case .housing: return "Sustainable housing"
        }
    }

    var subtitle: String {
        switch self {
        case .urbanRural: return "Slide between two ways of life"
        case .waterCycle: return "Track every drop from sea to sky and back"
        case .settlements: return "Grow a settlement from a home to a city"
        case .mangroveRoots: return "See how roots survive in soft, wet soil"
        case .housing: return "Turn housing problems into practical solutions"
        }
    }

    var symbol: String {
        switch self {
        case .urbanRural: return "building.2.fill"
        case .waterCycle: return "drop.fill"
        case .settlements: return "house.fill"
        case .mangroveRoots: return "tree.fill"
        case .housing: return "house.and.flag.fill"
        }
    }

    var tint: Color {
        switch self {
        case .urbanRural: return .purple
        case .waterCycle: return .blue
        case .settlements: return Color(red: 0.04, green: 0.47, blue: 0.51)
        case .mangroveRoots: return .green
        case .housing: return .orange
        }
    }

    @ViewBuilder
    var view: some View {
        switch self {
        case .urbanRural: HousingCompareView()
        case .waterCycle: WaterCycleView()
        case .settlements: SettlementHierarchyView()
        case .mangroveRoots: MangroveRootsView()
        case .housing: HousingSolutionsView()
        }
    }
}

private struct SimulationCard: View {
    let destination: SimulationDestination

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(destination.tint.opacity(0.16))
                Image(systemName: destination.symbol)
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundStyle(destination.tint)
            }
            .frame(width: 58, height: 58)

            VStack(alignment: .leading, spacing: 5) {
                Text(destination.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(destination.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 4)

            Image(systemName: "play.circle.fill")
                .font(.title2)
                .foregroundStyle(destination.tint)
        }
        .padding(17)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .shadow(color: .black.opacity(0.06), radius: 16, y: 7)
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens the simulation")
    }
}

private struct TopicCard: View {
    let topic: QuizTopic
    let record: ProgressStore.Record?

    private var quizSize: Int { min(QuizSession.questionsPerQuiz, topic.questions.count) }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(topic.tint.softColor)
                Image(systemName: topic.symbol)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(topic.tint.color)
            }
            .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 7) {
                Text(topic.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(topic.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 10) {
                    Text("\(quizSize) questions")
                    if let record, record.total > 0 {
                        Text("Best \(record.bestScore)/\(record.total)")
                            .foregroundStyle(topic.tint.color)
                    }
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

                if let record, record.total > 0 {
                    ProgressView(value: Double(record.bestScore), total: Double(record.total))
                        .tint(topic.tint.color)
                        .scaleEffect(x: 1, y: 0.7, anchor: .center)
                }
            }

            Spacer(minLength: 4)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.bold))
                .foregroundStyle(.tertiary)
                .padding(.top, 18)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .shadow(color: .black.opacity(0.05), radius: 18, y: 8)
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    TopicListView()
        .environmentObject(ProgressStore())
}
