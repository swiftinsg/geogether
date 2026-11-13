import SwiftUI

/// Shown after the last question: score, message and a full review.
struct ResultsView: View {
    let topic: QuizTopic
    let score: Int
    let attempts: [QuizSession.Attempt]
    let onRetry: () -> Void

    @Environment(\.dismiss) private var dismiss

    private var total: Int { topic.questions.count }
    private var fraction: Double { total == 0 ? 0 : Double(score) / Double(total) }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                summary
                review
                buttons
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
    }

    // MARK: - Summary

    private var summary: some View {
        QuizCard {
            VStack(spacing: 16) {
                ScoreRing(fraction: fraction, tint: topic.tint.color, lineWidth: 16)
                    .frame(width: 132, height: 132)
                    .padding(.top, 4)

                VStack(spacing: 6) {
                    Text(headline)
                        .font(.title2.weight(.bold))
                    Text("You answered \(score) of \(total) questions correctly.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                if score == total {
                    Label("Topic mastered", systemImage: "rosette")
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(topic.tint.color.opacity(0.15)))
                        .foregroundStyle(topic.tint.color)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var headline: String {
        switch fraction {
        case 1:            return "Perfect score!"
        case 0.8..<1:      return "Great work!"
        case 0.6..<0.8:    return "Good effort"
        default:           return "Keep practising"
        }
    }

    // MARK: - Review

    private var review: some View {
        QuizCard {
            VStack(alignment: .leading, spacing: 0) {
                Text("Review")
                    .font(.headline)
                    .padding(.bottom, 14)

                ForEach(Array(topic.questions.enumerated()), id: \.element.id) { index, question in
                    ReviewRow(
                        number: index + 1,
                        question: question,
                        attempt: attempts.indices.contains(index) ? attempts[index] : QuizSession.Attempt()
                    )

                    if index < topic.questions.count - 1 {
                        Divider().padding(.vertical, 12)
                    }
                }
            }
        }
    }

    // MARK: - Buttons

    private var buttons: some View {
        VStack(spacing: 12) {
            Button(action: onRetry) {
                Text("Try again")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(topic.tint.color)
                    )
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)

            Button {
                dismiss()
            } label: {
                Text("Back to topics")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color(.secondarySystemGroupedBackground))
                    )
                    .foregroundStyle(topic.tint.color)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(topic.tint.color.opacity(0.3), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 4)
    }
}

/// One line of the end-of-quiz review.
private struct ReviewRow: View {
    let number: Int
    let question: QuizQuestion
    let attempt: QuizSession.Attempt

    private var isCorrect: Bool { attempt.status == .correct }

    private var userAnswer: String {
        switch question.kind {
        case .fillInTheBlank:
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
