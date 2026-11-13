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
                progress.recordResult(for: topic, score: session.score)
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
                    onSubmit: checkIfReady
                )

                if session.currentAttempt.status != .unchecked {
                    FeedbackView(
                        question: session.currentQuestion,
                        status: session.currentAttempt.status,
                        userAnswer: session.currentUserAnswer
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                actionButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
        .scrollDismissesKeyboard(.interactively)
        .animation(.snappy, value: session.currentAttempt.status)
        .animation(.snappy, value: session.index)
    }

    private var progressHeader: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Question \(session.index + 1) of \(topic.questions.count)")
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

            ProgressView(value: Double(session.index + 1), total: Double(topic.questions.count))
                .tint(topic.tint.color)
        }
    }

    private var actionButton: some View {
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
            return "Check answer"
        }
        return session.isLastQuestion ? "See results" : "Next question"
    }

    private func primaryAction() {
        Keyboard.dismiss()
        if session.currentAttempt.status == .unchecked {
            withAnimation(.snappy) { session.checkCurrent() }
            playHaptic(success: session.currentAttempt.status == .correct)
        } else {
            withAnimation(.snappy) { session.next() }
        }
    }

    private func checkIfReady() {
        guard session.canCheck else { return }
        withAnimation(.snappy) { session.checkCurrent() }
        playHaptic(success: session.currentAttempt.status == .correct)
    }

    private func playHaptic(success: Bool) {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(success ? .success : .error)
        #endif
    }
}

/// The green / orange banner shown after a question is checked.
struct FeedbackView: View {
    let question: QuizQuestion
    let status: QuizSession.Status
    let userAnswer: String

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
                    Text("Well done — that's the right answer.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
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
