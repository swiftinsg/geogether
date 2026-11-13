import Foundation

/// Compares typed answers with the accepted answers in a forgiving way:
/// case, punctuation, extra spaces and leading articles are ignored.
enum AnswerChecker {
    static func isCorrect(question: QuizQuestion, texts: [String], order: [String]) -> Bool {
        switch question.kind {
        case .fillInTheBlank(let blanks):
            guard texts.count == blanks.count else { return false }
            return zip(texts, blanks).allSatisfy { input, blank in
                blank.accepted.contains { matches(input, $0) }
            }
        case .ordering(_, let correctOrder):
            guard order.count == correctOrder.count else { return false }
            return zip(order, correctOrder).allSatisfy { matches($0, $1) }
        case .shortAnswer:
            // Short answers are marked by the learner, not by text comparison.
            return false
        }
    }

    static func matches(_ input: String, _ expected: String) -> Bool {
        let value = normalize(input)
        let answer = normalize(expected)
        guard !value.isEmpty else { return false }
        return value == answer || compact(value) == compact(answer)
    }

    static func normalize(_ text: String) -> String {
        var value = text
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .replacingOccurrences(of: "’", with: "'")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        for article in ["the ", "a ", "an "] where value.hasPrefix(article) {
            value.removeFirst(article.count)
            break
        }

        // Keep letters, numbers and spaces only, so "4,000" and "MRT." work.
        value = String(value.map { character in
            character.isLetter || character.isNumber || character == " " ? character : " "
        })
        value = value.split(whereSeparator: \.isWhitespace).joined(separator: " ")
        return value
    }

    /// Removes spaces too, so "4 000" matches "4000".
    private static func compact(_ text: String) -> String {
        text.filter { $0.isLetter || $0.isNumber }
    }
}
