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

#Preview {
    TopicListView()
        .environmentObject(ProgressStore())
}
