import SwiftUI

/// One line in the quiz review.
struct ReviewRow: View {
    let number: Int
    let question: QuizQuestion
    let attempt: QuizSession.Attempt

    private var isCorrect: Bool { attempt.status == .correct }

    private var userAnswer: String {
        switch question.kind {
        case .fillInTheBlank, .shortAnswer:
            return attempt.texts
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .joined(separator: ", ")
        case .ordering:
            return attempt.order.joined(separator: " → ")
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.title3)
                .foregroundStyle(isCorrect ? .green : .orange)

            VStack(alignment: .leading, spacing: 6) {
                Text("Q\(number). \(question.prompt)")
                    .font(.subheadline.weight(.medium))
                    .lineLimit(2)

                Text("Answer: \(question.answerSummary)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                if !isCorrect && !userAnswer.isEmpty {
                    Text("You wrote: \(userAnswer)")
                        .font(.footnote)
                        .foregroundStyle(.orange)
                }
            }

            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }
}
