import SwiftUI

struct PollutionBattleDialogueView: View {
    @Environment(\.dismiss) private var dismiss

    let enemy: PollutionEnemy
    let onPurify: () -> Void

    @State private var selectedOption: Int?
    @State private var defeated = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [.purple, .black], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                header
                enemySummary
                quiz
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

            Text(enemy.pollutionType)
                .font(.headline)
                .foregroundStyle(.blue)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var enemySummary: some View {
        VStack(spacing: 10) {
            ShapeMonsterView(size: 90, isDefeated: defeated)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: defeated)

            Text(enemy.name)
                .font(.title3.bold())
                .foregroundStyle(.white)

            Text(selectedOption != nil ? enemy.question.explanation : enemy.topicLesson)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .foregroundStyle(.white)
                .padding(.horizontal)
        }
    }

    private var quiz: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Clean up the pollution")
                    .font(.headline)
                    .foregroundStyle(.blue)
                Text(enemy.question.prompt)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)

                ForEach(enemy.question.options.indices, id: \.self) { index in
                    Button {
                        selectAnswer(index)
                    } label: {
                        HStack {
                            Text(enemy.question.options[index])
                                .multilineTextAlignment(.leading)
                            Spacer()
                            if selectedOption == index {
                                Image(systemName: defeated ? "checkmark.circle.fill" : "xmark.circle.fill")
                            }
                        }
                        .padding(12)
                        .background(answerColor(index).opacity(0.45), in: RoundedRectangle(cornerRadius: 10))
                        .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                    .disabled(defeated)
                }

                if defeated {
                    Button("Restore this area") {
                        onPurify()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 6)
                }
            }
            .padding()
            .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal)
        }
    }

    private func selectAnswer(_ index: Int) {
        selectedOption = index
        defeated = index == enemy.question.correctIndex
        SoundManager.shared.play(defeated ? .quizCorrect : .quizWrong)
    }

    private func answerColor(_ index: Int) -> Color {
        guard selectedOption == index else { return .white.opacity(0.14) }
        return defeated ? .green : .red
    }
}
