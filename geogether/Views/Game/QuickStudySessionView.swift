import SwiftUI

struct QuickStudySessionView: View {
    private struct StudyItem: Identifiable {
        let id: UUID
        let topic: String
        let question: GeoQuestion
    }

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var curriculum: GeographyCurriculum

    @State private var selectedTopic = "All topics"
    @State private var currentIndex = 0
    @State private var selectedOption: Int?

    private var allItems: [StudyItem] {
        let questItems = curriculum.quests.map {
            StudyItem(id: $0.question.id, topic: $0.topic, question: $0.question)
        }
        let enemyItems = curriculum.enemies.map {
            StudyItem(id: $0.question.id, topic: $0.pollutionType, question: $0.question)
        }
        return questItems + enemyItems
    }

    private var availableTopics: [String] {
        ["All topics"] + Set(allItems.map(\.topic)).sorted()
    }

    private var filteredItems: [StudyItem] {
        guard selectedTopic != "All topics" else { return allItems }
        return allItems.filter { $0.topic == selectedTopic }
    }

    private var currentItem: StudyItem? {
        guard !filteredItems.isEmpty else { return nil }
        return filteredItems[currentIndex % filteredItems.count]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.08, green: 0.16, blue: 0.34), .black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 16) {
                    topicPicker

                    if let item = currentItem {
                        questionView(item)
                    } else {
                        ContentUnavailableView("No questions", systemImage: "questionmark.bubble")
                            .foregroundStyle(.white)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Quick Study")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.blue)
                    .bold()
                }
            }
        }
        .tint(.blue)
    }

    private var topicPicker: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("Choose a topic")
                .font(.caption.bold())
                .foregroundStyle(.blue)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(availableTopics, id: \.self) { topic in
                        Button(topic) {
                            chooseTopic(topic)
                        }
                        .font(.caption.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedTopic == topic ? .blue : .white.opacity(0.14), in: Capsule())
                        .foregroundStyle(.white)
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private func questionView(_ item: StudyItem) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(item.topic)
                        .font(.caption.bold())
                        .foregroundStyle(.blue)
                    Spacer()
                    Text("\((currentIndex % filteredItems.count) + 1) of \(filteredItems.count)")
                        .font(.caption.bold())
                        .foregroundStyle(.blue)
                }

                Text(item.question.prompt)
                    .font(.headline)
                    .foregroundStyle(.white)

                ForEach(item.question.options.indices, id: \.self) { index in
                    Button {
                        chooseAnswer(index, for: item.question)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: optionSymbol(index, question: item.question))
                            Text(item.question.options[index])
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 0)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(optionColor(index, question: item.question).opacity(0.24), in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                    .disabled(selectedOption == item.question.correctIndex)
                }

                if let selectedOption {
                    Text(item.question.explanation)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            (selectedOption == item.question.correctIndex ? Color.green : Color.red).opacity(0.2),
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                }

                Button("Next question", action: nextQuestion)
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 18))
            .padding(.horizontal)
        }
    }

    private func chooseTopic(_ topic: String) {
        selectedTopic = topic
        currentIndex = 0
        selectedOption = nil
    }

    private func chooseAnswer(_ index: Int, for question: GeoQuestion) {
        selectedOption = index
        SoundManager.shared.play(index == question.correctIndex ? .quizCorrect : .quizWrong)
    }

    private func nextQuestion() {
        currentIndex += 1
        selectedOption = nil
    }

    private func optionSymbol(_ index: Int, question: GeoQuestion) -> String {
        guard let selectedOption else { return "circle" }
        if index == question.correctIndex { return "checkmark.circle.fill" }
        if index == selectedOption { return "xmark.circle.fill" }
        return "circle"
    }

    private func optionColor(_ index: Int, question: GeoQuestion) -> Color {
        guard let selectedOption else { return .white }
        if index == question.correctIndex { return .green }
        if index == selectedOption { return .red }
        return .white
    }
}
