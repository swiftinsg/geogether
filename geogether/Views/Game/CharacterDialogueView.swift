import SwiftUI

struct CharacterDialogueView: View {
    private enum Stage: Int, CaseIterable {
        case study
        case background
        case quiz

        var title: String {
            switch self {
            case .study: return "Study"
            case .background: return "Character"
            case .quiz: return "Quiz"
            }
        }
    }

    @Environment(\.dismiss) private var dismiss

    let quest: GeoQuest
    let currentLevel: Int
    let canLevelUp: Bool
    let levelUp: () -> Void

    @State private var stage = Stage.study
    @State private var selectedOption: Int?
    @State private var isCorrect = false
    @State private var didAwardLevel = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.12, green: 0.17, blue: 0.34), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 14) {
                header
                stageIndicator

                ScrollView {
                    Group {
                        switch stage {
                        case .study:
                            StudyStageView(quest: quest)
                        case .background:
                            CharacterBackgroundView(quest: quest)
                        case .quiz:
                            quizStage
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }

                navigationButton
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }
        }
    }

    private var header: some View {
        HStack {
            Button("Leave") {
                dismiss()
            }
            .buttonStyle(.bordered)
            .tint(.white)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(quest.zoneName)
                    .font(.headline)
                    .foregroundStyle(.blue)
                Text("Level \(didAwardLevel ? currentLevel + 1 : currentLevel)")
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var stageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(Stage.allCases, id: \.self) { item in
                HStack(spacing: 5) {
                    Image(systemName: item.rawValue < stage.rawValue ? "checkmark.circle.fill" : "circle.fill")
                    Text(item.title)
                }
                .font(.caption.bold())
                .foregroundStyle(item.rawValue <= stage.rawValue ? .blue : .white.opacity(0.35))

                if item != .quiz {
                    Rectangle()
                        .fill(item.rawValue < stage.rawValue ? .blue : .white.opacity(0.2))
                        .frame(height: 2)
                }
            }
        }
        .padding(.horizontal)
    }

    private var quizStage: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Check your understanding")
                .font(.title3.bold())
                .foregroundStyle(.blue)

            Text(quest.question.prompt)
                .font(.headline)
                .foregroundStyle(.white)

            ForEach(quest.question.options.indices, id: \.self) { index in
                Button {
                    selectAnswer(index)
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: answerSymbol(for: index))
                        Text(quest.question.options[index])
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 0)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(answerColor(for: index).opacity(0.26), in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .disabled(isCorrect)
            }

            if selectedOption != nil {
                Text(quest.question.explanation)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background((isCorrect ? Color.green : Color.red).opacity(0.2), in: RoundedRectangle(cornerRadius: 12))
            }

            if isCorrect {
                LevelUpCard(level: didAwardLevel ? currentLevel + 1 : currentLevel, awarded: didAwardLevel)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding()
        .background(.black.opacity(0.45), in: RoundedRectangle(cornerRadius: 20))
    }

    @ViewBuilder
    private var navigationButton: some View {
        switch stage {
        case .study:
            Button("Meet \(quest.npcName)") {
                withAnimation(.snappy) {
                    stage = .background
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .controlSize(.large)
        case .background:
            Button("Next: quiz") {
                withAnimation(.snappy) {
                    stage = .quiz
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .controlSize(.large)
        case .quiz:
            if isCorrect {
                Button("Return to world") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .controlSize(.large)
            }
        }
    }

    private func selectAnswer(_ index: Int) {
        selectedOption = index
        guard index == quest.question.correctIndex else {
            isCorrect = false
            SoundManager.shared.play(.quizWrong)
            return
        }

        withAnimation(.spring()) {
            isCorrect = true
            if canLevelUp && !didAwardLevel {
                didAwardLevel = true
                levelUp()
            }
        }
        SoundManager.shared.play(.quizCorrect)
    }

    private func answerSymbol(for index: Int) -> String {
        guard let selectedOption else { return "circle" }
        if index == quest.question.correctIndex, isCorrect { return "checkmark.circle.fill" }
        if index == selectedOption { return "xmark.circle.fill" }
        return "circle"
    }

    private func answerColor(for index: Int) -> Color {
        guard let selectedOption else { return .white }
        if index == quest.question.correctIndex, isCorrect { return .green }
        if index == selectedOption { return .red }
        return .white
    }
}

private struct StudyStageView: View {
    let quest: GeoQuest

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Field notes", systemImage: "book.pages.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.72))

            Text(quest.topic)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)

            ForEach(quest.fieldNotes, id: \.self) { note in
                HStack(alignment: .top, spacing: 9) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .foregroundStyle(.blue)
                        .padding(.top, 6)
                    Text(note.replacingOccurrences(of: "• ", with: ""))
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                }
            }

            if let destination = quest.relatedSimulation {
                Divider()
                    .overlay(.white.opacity(0.14))
                    .padding(.vertical, 4)

                InlineGameSimulationView(destination: destination)
            }
        }
        .padding()
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.white.opacity(0.09), lineWidth: 1)
        }
    }
}

private struct InlineGameSimulationView: View {
    let destination: SimulationDestination

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 10) {
                Image(systemName: destination.symbol)
                    .font(.headline)
                    .foregroundStyle(destination.tint)
                    .frame(width: 34, height: 34)
                    .background(destination.tint.opacity(0.14), in: Circle())

                VStack(alignment: .leading, spacing: 1) {
                    Text(destination.title)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("Use the controls below.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.62))
                }
            }

            destination.view
                .environment(\.isEmbeddedSimulation, true)
                .environment(\.colorScheme, .dark)
                .frame(height: preferredHeight)
                .clipped()
        }
    }

    private var preferredHeight: CGFloat {
        switch destination {
        case .settlements: return 620
        case .urbanRural: return 720
        case .mangroveRoots: return 610
        case .housing: return 680
        case .geoWorld, .waterCycle: return 620
        }
    }
}

private struct CharacterBackgroundView: View {
    let quest: GeoQuest

    var body: some View {
        VStack(spacing: 14) {
            ZStack(alignment: .bottom) {
                GeographyStageBackdrop(questId: quest.id, isSolved: quest.isCompleted)
                ShapeCatView(
                    bodyColor: catColor,
                    size: 92,
                    isMayor: quest.id == "hierarchy"
                )
            }

            Text(quest.npcName)
                .font(.title3.bold())
                .foregroundStyle(.white)

            Text(quest.storyText)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.9))
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private var catColor: Color {
        switch quest.npcShapeColor {
        case "orange": return .orange
        case "purple": return .purple
        case "cyan": return .cyan
        case "green", "mint": return .mint
        case "blue": return .blue
        case "yellow": return .yellow
        case "indigo": return .indigo
        default: return .pink
        }
    }
}

private struct LevelUpCard: View {
    let level: Int
    let awarded: Bool

    var body: some View {
        VStack(spacing: 7) {
            Image(systemName: awarded ? "arrow.up.circle.fill" : "checkmark.seal.fill")
                .font(.largeTitle)
                .foregroundStyle(.blue)
            Text(awarded ? "Level up" : "Review complete")
                .font(.title3.bold())
                .foregroundStyle(.white)
            Text(awarded ? "You reached level \(level)." : "You already mastered this quest.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.blue.opacity(0.24), in: RoundedRectangle(cornerRadius: 16))
    }
}
