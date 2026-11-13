import SwiftUI

/// Shows one question, with the input control that matches its kind.
/// Exactly one of these is on screen at a time.
struct QuestionCardView: View {
    @ObservedObject var session: QuizSession
    let tint: Color
    var onSubmit: () -> Void = {}

    @FocusState private var focusedBlank: Int?

    private var question: QuizQuestion { session.currentQuestion }
    private var attempt: QuizSession.Attempt { session.currentAttempt }
    private var isChecked: Bool { attempt.status != .unchecked }

    var body: some View {
        QuizCard {
            VStack(alignment: .leading, spacing: 16) {
                header

                Text(question.prompt)
                    .font(.title3)
                    .fontWeight(.medium)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)

                if let hint = question.hint, !isChecked {
                    hintRow(hint)
                }

                switch question.kind {
                case .fillInTheBlank(let blanks):
                    VStack(spacing: 10) {
                        ForEach(blanks.indices, id: \.self) { index in
                            blankField(index: index, total: blanks.count)
                        }
                    }
                case .ordering(let options, _):
                    orderingArea(options: options)
                }
            }
        }
        .onChange(of: session.index) { _, _ in focusedBlank = nil }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Q\(session.index + 1)")
                .font(.caption.weight(.bold))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(tint.opacity(0.15)))
                .foregroundStyle(tint)

            Spacer()

            Text(question.instruction)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }

    private func hintRow(_ hint: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "lightbulb.fill")
                .font(.caption)
                .foregroundStyle(.yellow)
            Text(hint)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.tertiarySystemFill))
        )
    }

    // MARK: - Fill in the blank

    private func blankField(index: Int, total: Int) -> some View {
        HStack(spacing: 10) {
            if total > 1 {
                NumberBadge(number: index + 1, tint: tint)
            }

            TextField(total > 1 ? "Answer \(index + 1)" : "Type your answer", text: textBinding(index))
                .focused($focusedBlank, equals: index)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(index == total - 1 ? .done : .next)
                .onSubmit {
                    if index < total - 1 {
                        focusedBlank = index + 1
                    } else {
                        focusedBlank = nil
                        onSubmit()
                    }
                }
                .disabled(isChecked)
                .font(.body.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(.tertiarySystemFill))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(borderColor, lineWidth: 1.5)
                )
        }
    }

    private var borderColor: Color {
        switch attempt.status {
        case .unchecked: return Color.primary.opacity(0.08)
        case .correct:   return .green.opacity(0.75)
        case .incorrect: return .orange.opacity(0.85)
        }
    }

    private func textBinding(_ index: Int) -> Binding<String> {
        Binding(
            get: {
                let texts = session.currentAttempt.texts
                return texts.indices.contains(index) ? texts[index] : ""
            },
            set: { session.setText($0, at: index) }
        )
    }

    // MARK: - Ordering

    private func orderingArea(options: [String]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Your order")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                if !attempt.order.isEmpty && !isChecked {
                    Button("Clear") { session.resetOrdering() }
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(tint)
                }
            }

            HStack(spacing: 8) {
                if attempt.order.isEmpty {
                    Text("Tap the options below, smallest first")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(Array(attempt.order.enumerated()), id: \.offset) { position, item in
                        Button {
                            session.toggleOrderingOption(item)
                        } label: {
                            HStack(spacing: 6) {
                                Text("\(position + 1)")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(tint)
                                Text(item)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(tint.opacity(0.15)))
                        }
                        .buttonStyle(.plain)
                        .disabled(isChecked)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .frame(minHeight: 54)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(
                        borderColor,
                        style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                    )
            )

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: 8)], alignment: .leading, spacing: 8) {
                ForEach(options, id: \.self) { option in
                    let chosen = attempt.order.contains(option)
                    Button {
                        session.toggleOrderingOption(option)
                    } label: {
                        Text(option)
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color(.tertiarySystemFill))
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(chosen || isChecked)
                    .opacity(chosen ? 0.35 : 1)
                }
            }
        }
    }
}
