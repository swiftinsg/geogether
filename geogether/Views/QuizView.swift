import SwiftUI

/// Runs one topic: one question per page, with a progress bar and a Check button.
struct QuizView: View {
    let topic: QuizTopic

    @EnvironmentObject private var progress: ProgressStore
    @StateObject private var session: QuizSession

    init(topic: QuizTopic) {
        self.topic = topic
        _session = StateObject(wrappedValue: QuizSession(topic: topic))
    }

    var body: some View {
        ZStack {
            AppBackground(tint: topic.tint.color)

            if session.showingResults {
                ResultsView(
                    topic: topic,
                    questions: session.questions,
                    score: session.score,
                    attempts: session.attempts,
                    onRetry: { session.restart() }
                )
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            } else {
                questionPage
            }
        }
        .navigationTitle(session.showingResults ? "Results" : topic.title)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: session.showingResults) { _, showing in
            if showing {
                progress.recordResult(for: topic, score: session.score, total: session.questions.count)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { Keyboard.dismiss() }
            }
        }
    }

    // MARK: - One page per question

    private var questionPage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                progressHeader

                QuestionCardView(
                    session: session,
                    tint: topic.tint.color,
                    onSubmit: submitFromKeyboard
                )

                if awaitingSelfMark, let modelAnswer = session.currentQuestion.modelAnswer {
                    ModelAnswerCard(modelAnswer: modelAnswer, tint: topic.tint.color)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                if session.currentAttempt.status != .unchecked {
                    FeedbackView(
                        question: session.currentQuestion,
                        status: session.currentAttempt.status,
                        userAnswer: session.currentUserAnswer,
                        modelAnswer: session.currentQuestion.modelAnswer
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                actionArea
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
        .scrollDismissesKeyboard(.interactively)
        .animation(.snappy, value: session.currentAttempt.status)
        .animation(.snappy, value: session.currentAttempt.revealed)
        .animation(.snappy, value: session.index)
    }

    private var progressHeader: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Question \(session.index + 1) of \(session.questions.count)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                if session.index > 0 {
                    Button {
                        Keyboard.dismiss()
                        session.previous()
                    } label: {
                        Label("Previous", systemImage: "chevron.left")
                            .font(.footnote.weight(.semibold))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(topic.tint.color)
                }
            }

            ProgressView(value: Double(session.index + 1), total: Double(session.questions.count))
                .tint(topic.tint.color)
        }
    }

    // MARK: - Buttons

    private var isShortAnswer: Bool { session.currentQuestion.modelAnswer != nil }

    /// A short-answer question whose model answer is showing, waiting to be self-marked.
    private var awaitingSelfMark: Bool {
        isShortAnswer && session.currentAttempt.revealed && session.currentAttempt.status == .unchecked
    }

    @ViewBuilder
    private var actionArea: some View {
        if awaitingSelfMark {
            HStack(spacing: 12) {
                selfMarkButton(title: "Not quite", symbol: "xmark", tint: .orange, correct: false)
                selfMarkButton(title: "Got it", symbol: "checkmark", tint: .green, correct: true)
            }
            .padding(.top, 2)
        } else {
            primaryButton
        }
    }

    private func selfMarkButton(title: String, symbol: String, tint: Color, correct: Bool) -> some View {
        Button {
            Keyboard.dismiss()
            withAnimation(.snappy) { session.selfMark(correct) }
            playHaptic(success: correct)
        } label: {
            Label(title, systemImage: symbol)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(tint.opacity(0.15))
                )
                .foregroundStyle(tint)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(tint.opacity(0.35), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var primaryButton: some View {
        Button(action: primaryAction) {
            Text(primaryButtonTitle)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(canAct ? topic.tint.color : Color(.systemGray3))
                )
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
        .disabled(!canAct)
        .animation(.easeInOut(duration: 0.2), value: canAct)
        .padding(.top, 2)
    }

    private var canAct: Bool {
        session.currentAttempt.status == .unchecked ? session.canCheck : true
    }

    private var primaryButtonTitle: String {
        if session.currentAttempt.status == .unchecked {
            return isShortAnswer ? "Show answer" : "Check answer"
        }
        return session.isLastQuestion ? "See results" : "Next question"
    }

    private func primaryAction() {
        Keyboard.dismiss()
        if session.currentAttempt.status == .unchecked {
            withAnimation(.snappy) {
                if isShortAnswer {
                    session.revealAnswer()
                } else {
                    session.checkCurrent()
                }
            }
            if !isShortAnswer {
                playHaptic(success: session.currentAttempt.status == .correct)
            }
        } else {
            withAnimation(.snappy) { session.next() }
        }
    }

    private func submitFromKeyboard() {
        guard session.canCheck else { return }
        withAnimation(.snappy) {
            if isShortAnswer {
                session.revealAnswer()
            } else {
                session.checkCurrent()
                playHaptic(success: session.currentAttempt.status == .correct)
            }
        }
    }

    private func playHaptic(success: Bool) {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(success ? .success : .error)
        #endif
    }
}

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
