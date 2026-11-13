import Combine
import Foundation

/// Holds the state of one run through a topic: which question is on screen,
/// what the learner typed, and whether each answer was checked.
final class QuizSession: ObservableObject {
    enum Status: Equatable {
        case unchecked, correct, incorrect
    }

    struct Attempt: Equatable {
        var texts: [String] = []
        var order: [String] = []
        var status: Status = .unchecked
    }

    let topic: QuizTopic
    @Published var index: Int = 0
    @Published var attempts: [Attempt]
    @Published var showingResults = false

    init(topic: QuizTopic) {
        self.topic = topic
        self.attempts = Self.freshAttempts(for: topic)
    }

    var currentQuestion: QuizQuestion { topic.questions[index] }
    var currentAttempt: Attempt { attempts[index] }
    var score: Int { attempts.filter { $0.status == .correct }.count }
    var isLastQuestion: Bool { index == topic.questions.count - 1 }

    /// The Check button is only enabled once every blank / slot is filled in.
    var canCheck: Bool {
        guard currentAttempt.status == .unchecked else { return false }
        switch currentQuestion.kind {
        case .fillInTheBlank(let blanks):
            guard currentAttempt.texts.count == blanks.count else { return false }
            return currentAttempt.texts.allSatisfy {
                !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
        case .ordering(let options, _):
            return currentAttempt.order.count == options.count
        }
    }

    func checkCurrent() {
        guard canCheck else { return }
        let correct = AnswerChecker.isCorrect(
            question: currentQuestion,
            texts: currentAttempt.texts,
            order: currentAttempt.order
        )
        updateCurrent { $0.status = correct ? .correct : .incorrect }
    }

    func setText(_ text: String, at index: Int) {
        guard currentAttempt.status == .unchecked else { return }
        updateCurrent { attempt in
            guard attempt.texts.indices.contains(index) else { return }
            attempt.texts[index] = text
        }
    }

    func toggleOrderingOption(_ option: String) {
        guard currentAttempt.status == .unchecked else { return }
        updateCurrent { attempt in
            if let existing = attempt.order.firstIndex(of: option) {
                attempt.order.remove(at: existing)
            } else {
                attempt.order.append(option)
            }
        }
    }

    func resetOrdering() {
        guard currentAttempt.status == .unchecked else { return }
        updateCurrent { $0.order.removeAll() }
    }

    func next() {
        if isLastQuestion {
            showingResults = true
        } else {
            index += 1
        }
    }

    func previous() {
        guard index > 0 else { return }
        index -= 1
    }

    func restart() {
        attempts = Self.freshAttempts(for: topic)
        index = 0
        showingResults = false
    }

    /// A readable version of whatever the learner entered, for the review list.
    var currentUserAnswer: String { userAnswer(for: currentQuestion, attempt: currentAttempt) }

    func userAnswer(for question: QuizQuestion, attempt: Attempt) -> String {
        switch question.kind {
        case .fillInTheBlank:
            let filled = attempt.texts
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            return filled.joined(separator: ", ")
        case .ordering:
            return attempt.order.joined(separator: " → ")
        }
    }

    private func updateCurrent(_ change: (inout Attempt) -> Void) {
        var attempt = attempts[index]
        change(&attempt)
        attempts[index] = attempt
    }

    private static func freshAttempts(for topic: QuizTopic) -> [Attempt] {
        topic.questions.map { question in
            switch question.kind {
            case .fillInTheBlank(let blanks):
                return Attempt(texts: Array(repeating: "", count: blanks.count))
            case .ordering:
                return Attempt()
            }
        }
    }
}
