import SwiftUI

/// A group of related questions, e.g. "Housing" or "Mangrove ecosystems".
struct QuizTopic: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let symbol: String
    let tint: TopicTint
    let questions: [QuizQuestion]
}

/// The accent colours used by each topic.
enum TopicTint: String, Hashable {
    case teal, orange, green, blue, purple, pink

    var color: Color {
        switch self {
        case .teal:   return Color(red: 0.04, green: 0.47, blue: 0.51)
        case .orange: return Color(red: 0.82, green: 0.42, blue: 0.05)
        case .green:  return Color(red: 0.13, green: 0.47, blue: 0.28)
        case .blue:   return Color(red: 0.10, green: 0.36, blue: 0.78)
        case .purple: return Color(red: 0.43, green: 0.22, blue: 0.85)
        case .pink:   return Color(red: 0.80, green: 0.15, blue: 0.45)
        }
    }

    var softColor: Color { color.opacity(0.14) }
}

/// A single question. Every question is shown on its own page.
struct QuizQuestion: Identifiable, Hashable {
    enum Kind: Hashable {
        /// One or more "fill in the blank" answers.
        case fillInTheBlank([Blank])
        /// Put a set of options into the correct order.
        case ordering(options: [String], correctOrder: [String])
    }

    let id: String
    let prompt: String
    let hint: String?
    let kind: Kind

    var instruction: String {
        switch kind {
        case .fillInTheBlank(let blanks):
            return blanks.count == 1 ? "Fill in the blank" : "Fill in both blanks"
        case .ordering:
            return "Put these in the correct order"
        }
    }

    var blanks: [Blank] {
        if case .fillInTheBlank(let blanks) = kind { return blanks }
        return []
    }

    /// The answer key used when revealing the correct answer.
    var answerSummary: String {
        switch kind {
        case .fillInTheBlank(let blanks):
            return blanks.map(\.display).joined(separator: ", ")
        case .ordering(_, let correctOrder):
            return correctOrder.joined(separator: " → ")
        }
    }
}

/// One blank in a fill-in-the-blank question.
struct Blank: Hashable {
    /// Every spelling that should be accepted.
    let accepted: [String]
    /// The answer shown to the learner, e.g. "services / infrastructure".
    let display: String
}
