import SwiftUI

struct TopicCard: View {
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
