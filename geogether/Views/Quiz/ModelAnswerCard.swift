import SwiftUI

/// Reveals the model answer of a short-answer question.
struct ModelAnswerCard: View {
    let modelAnswer: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Model answer", systemImage: "text.book.closed.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(tint)

            Text(modelAnswer)
                .font(.subheadline)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            Text("Mark yourself honestly using the buttons below.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
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
