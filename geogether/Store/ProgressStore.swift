import Combine
import Foundation

/// Tracks the best score for each topic between launches.
final class ProgressStore: ObservableObject {
    struct Record: Codable, Equatable {
        var bestScore: Int
        var total: Int
        var attempts: Int
    }

    @Published private(set) var records: [String: Record] = [:]

    private let defaults: UserDefaults
    private let storageKey = "geography-quiz.progress.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    func bestScore(for topicID: String) -> Int? {
        records[topicID].map(\.bestScore)
    }

    /// Best score as a 0...1 fraction, or nil if the topic was never finished.
    func bestFraction(for topic: QuizTopic) -> Double? {
        guard let record = records[topic.id], record.total > 0 else { return nil }
        return Double(record.bestScore) / Double(record.total)
    }

    func recordResult(for topic: QuizTopic, score: Int, total: Int) {
        var record = records[topic.id] ?? Record(bestScore: 0, total: total, attempts: 0)
        record.bestScore = max(record.bestScore, score)
        record.total = total
        record.attempts += 1
        records[topic.id] = record
        save()
    }

    func resetAll() {
        records = [:]
        save()
    }

    private func load() {
        guard let data = defaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([String: Record].self, from: data) else { return }
        records = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(records) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
