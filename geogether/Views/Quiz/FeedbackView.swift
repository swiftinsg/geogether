import SwiftUI

/// The green / orange banner shown after a question is checked.
struct FeedbackView: View {
    let question: QuizQuestion
    let status: QuizSession.Status
    let userAnswer: String
    var modelAnswer: String?

    private var isCorrect: Bool { status == .correct }
    private var tint: Color { isCorrect ? .green : .orange }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "lightbulb.circle.fill")
                .font(.title3)
                .foregroundStyle(tint)

            VStack(alignment: .leading, spacing: 5) {
                Text(isCorrect ? "Correct!" : "Not quite")
                    .font(.headline)
                    .foregroundStyle(tint)

                if isCorrect {
                    if let modelAnswer {
                        Text("Model answer: \(modelAnswer)")
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                    } else {
                        Text("Well done — that's the right answer.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("Correct answer: \(question.answerSummary)")
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    if !userAnswer.isEmpty {
                        Text("You wrote: \(userAnswer)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(tint.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(tint.opacity(0.25), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }
}
