import SwiftUI

/// Home screen: the question bank split into its six topics.
struct TopicListView: View {
    @EnvironmentObject private var progress: ProgressStore

    private var topics: [QuizTopic] { QuestionBank.topics }
    private var totalQuestions: Int { topics.reduce(0) { $0 + $1.questions.count } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header

                    VStack(spacing: 14) {
                        ForEach(topics) { topic in
                            NavigationLink(value: topic) {
                                TopicCard(topic: topic, record: progress.records[topic.id])
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Text("One question per page. Tap Check answer to mark each question, then review your score at the end.")
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
            .background(AppBackground())
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: QuizTopic.self) { topic in
                QuizView(topic: topic)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Geography")
                .font(.system(size: 38, weight: .bold, design: .rounded))
            Text("Simulation question bank")
                .font(.title3)
                .foregroundStyle(.secondary)

            HStack(spacing: 14) {
                Label("\(topics.count) topics", systemImage: "square.stack.3d.up.fill")
                Label("\(totalQuestions) questions", systemImage: "questionmark.circle.fill")
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
                    Text("\(topic.questions.count) questions")
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
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
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
