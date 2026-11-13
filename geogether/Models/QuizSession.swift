import Combine
import Foundation

/// Holds the state of one run through a topic: which questions were drawn,
/// which one is on screen, and what the learner answered.
final class QuizSession: ObservableObject {
    /// How many questions a single quiz contains.
    static let questionsPerQuiz = 10

    enum Status: Equatable {
        case unchecked, correct, incorrect
    }

    struct Attempt: Equatable {
        var texts: [String] = []
        var order: [String] = []
        /// True once the model answer of a short-answer question has been shown.
        var revealed = false
        var status: Status = .unchecked
    }

    let topic: QuizTopic
    /// The questions drawn for this run (a random subset of the topic's bank).
    @Published private(set) var questions: [QuizQuestion]
    @Published var index: Int = 0
    @Published var attempts: [Attempt]
    @Published var showingResults = false

    private let questionsToDraw: Int

    init(topic: QuizTopic, questionCount: Int = QuizSession.questionsPerQuiz) {
        self.topic = topic
        self.questionsToDraw = questionCount
        let drawn = Self.draw(from: topic.questions, count: questionCount)
        self.questions = drawn
        self.attempts = Self.freshAttempts(for: drawn)
    }

    var currentQuestion: QuizQuestion { questions[index] }
    var currentAttempt: Attempt { attempts[index] }
    var score: Int { attempts.filter { $0.status == .correct }.count }
    var isLastQuestion: Bool { index == questions.count - 1 }

    /// The Check button is only enabled once every blank / slot is filled in.
    /// Short-answer questions can always be revealed.
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
        case .shortAnswer:
            return !currentAttempt.revealed
        }
    }

    func checkCurrent() {
        guard canCheck else { return }
        guard currentQuestion.modelAnswer == nil else { return }
        let correct = AnswerChecker.isCorrect(
            question: currentQuestion,
            texts: currentAttempt.texts,
            order: currentAttempt.order
        )
        updateCurrent { $0.status = correct ? .correct : .incorrect }
    }

    /// Shows the model answer of a short-answer question.
    func revealAnswer() {
        guard currentQuestion.modelAnswer != nil, currentAttempt.status == .unchecked else { return }
        updateCurrent { $0.revealed = true }
    }

    /// Records the learner's own judgement of a short-answer question.
    func selfMark(_ correct: Bool) {
        guard currentQuestion.modelAnswer != nil else { return }
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

    /// Starts a brand new quiz: a fresh random set of questions, shuffled again.
    func restart() {
        let drawn = Self.draw(from: topic.questions, count: questionsToDraw)
        questions = drawn
        attempts = Self.freshAttempts(for: drawn)
        index = 0
        showingResults = false
    }

    /// A readable version of whatever the learner entered, for the review list.
    var currentUserAnswer: String { userAnswer(for: currentQuestion, attempt: currentAttempt) }

    func userAnswer(for question: QuizQuestion, attempt: Attempt) -> String {
        switch question.kind {
        case .fillInTheBlank, .shortAnswer:
            let filled = attempt.texts
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            return filled.joined(separator: ", ")
        case .ordering:
            return attempt.order.joined(separator: " → ")
        }
    }

    // MARK: - Drawing random questions

    /// Picks `count` questions at random and shuffles their order.
    nonisolated private static func draw(from pool: [QuizQuestion], count: Int) -> [QuizQuestion] {
        pool.shuffled().prefix(count).map(shufflingOptions)
    }

    /// For ordering questions, the options are shuffled too so the correct
    /// sequence is never in a predictable place.
    nonisolated private static func shufflingOptions(_ question: QuizQuestion) -> QuizQuestion {
        guard case .ordering(let options, let correctOrder) = question.kind, options.count > 1 else {
            return question
        }

        var shuffled = options.shuffled()
        var guardCount = 0
        while shuffled == correctOrder && guardCount < 20 {
            shuffled = options.shuffled()
            guardCount += 1
        }

        return QuizQuestion(
            id: question.id,
            section: question.section,
            prompt: question.prompt,
            hint: question.hint,
            kind: .ordering(options: shuffled, correctOrder: correctOrder)
        )
    }

    private func updateCurrent(_ change: (inout Attempt) -> Void) {
        var attempt = attempts[index]
        change(&attempt)
        attempts[index] = attempt
    }

    private static func freshAttempts(for questions: [QuizQuestion]) -> [Attempt] {
        questions.map { question in
            switch question.kind {
            case .fillInTheBlank(let blanks):
                return Attempt(texts: Array(repeating: "", count: blanks.count))
            case .ordering:
                return Attempt()
            case .shortAnswer:
                return Attempt(texts: [""])
            }
        }
    }
}
