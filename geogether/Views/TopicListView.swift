import SwiftUI

/// Home screen: the question bank split into its six topics.
struct TopicListView: View {
    @EnvironmentObject private var progress: ProgressStore
    var onBack: (() -> Void)?

    init(onBack: (() -> Void)? = nil) {
        self.onBack = onBack
    }

    private var topics: [QuizTopic] { QuestionBank.topics }
    private var totalQuestions: Int { topics.reduce(0) { $0 + $1.questions.count } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header

                    VStack(spacing: 14) {
                        ForEach(topics) { topic in
                            VStack(spacing: 0) {
                                NavigationLink(value: topic) {
                                    TopicCard(topic: topic, record: progress.records[topic.id])
                                }
                                .buttonStyle(.plain)

                                if let lesson = lessonDestination(for: topic) {
                                    NavigationLink(value: lesson) {
                                        Label("Explore interactive lesson", systemImage: "sparkles")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(topic.tint.color)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 11)
                                            .background(
                                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                    .fill(topic.tint.softColor)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.top, -7)
                                    .padding(.horizontal, 14)
                                }
                            }
                        }
                    }

                    Text("Each quiz picks \(QuizSession.questionsPerQuiz) random questions from the topic, in a random order — so no two quizzes are the same.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
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
            .navigationDestination(for: LessonDestination.self) { lesson in
                switch lesson {
                case .urbanAndRural:
                    HousingCompareView()
                case .waterCycle:
                    WaterCycleView()
                }
            }
        }
    }

    private func lessonDestination(for topic: QuizTopic) -> LessonDestination? {
        switch topic.id {
        case "urban-studies": return .urbanAndRural
        case "hydrological-cycle": return .waterCycle
        default: return nil
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Choose a topic")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(AppPalette.navy)
            Text("Explore an interactive lesson or test what you know.")
                .font(.title3)
                .foregroundStyle(.secondary)

            HStack(spacing: 14) {
                Label("\(topics.count) topics", systemImage: "square.stack.3d.up.fill")
                Label("\(totalQuestions) questions in the bank", systemImage: "questionmark.circle.fill")
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A tappable topic summary on the home screen.
private struct TopicCard: View {
    let topic: QuizTopic
    let record: ProgressStore.Record?

    private var quizSize: Int { min(QuizSession.questionsPerQuiz, topic.questions.count) }

    private var quizDescription: String {
        topic.questions.count > quizSize
            ? "\(quizSize) random of \(topic.questions.count) questions"
            : "\(quizSize) questions"
    }

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
                    Text(quizDescription)
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
                        .padding(.top, 2)
                }
            }

            Spacer(minLength: 4)

            VStack(spacing: 10) {
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(.tertiary)

                if topic.id == "urban-studies" || topic.id == "hydrological-cycle" {
                    Text("Quiz")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(topic.tint.color)
                }
            }
            .padding(.top, 18)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 18, y: 8)
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .accessibilityElement(children: .combine)

    }
}

private enum LessonDestination: Hashable {
    case urbanAndRural
    case waterCycle
}

#Preview {
    TopicListView()
        .environmentObject(ProgressStore())
}
