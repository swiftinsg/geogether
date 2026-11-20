import SwiftUI
import SpriteKit

struct GeoWorldView: View {
    @StateObject private var curriculum = GeographyCurriculum()
    @State private var scene = OpenWorldScene(size: CGSize(width: 1000, height: 800))
    @State private var coordinator = SceneCoordinator()

    @State private var activeQuest: GeoQuest?
    @State private var activeEnemy: PollutionEnemy?
    @State private var showFieldGuide = false
    @State private var currentZone = "Central Crossroads"

    @State private var pressedKeys: Set<KeyEquivalent> = []
    @FocusState private var isGameFocused: Bool

    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .ignoresSafeArea()
                .focusable()
                .focused($isGameFocused)
                .onKeyPress(phases: [.down, .up]) { press in
                    handleKeyPress(press)
                    return .handled
                }

            VStack {
                topHUD
                Spacer()
                bottomControls
            }
            .padding()
        }
        .onAppear {
            scene.scaleMode = .resizeFill
            scene.curriculum = curriculum
            coordinator.parent = self
            scene.worldDelegate = coordinator
            isGameFocused = true
        }
        .fullScreenCover(item: $activeQuest) { quest in
            CharacterDialogueView(quest: quest) {
                completeQuest(id: quest.id)
                activeQuest = nil
                isGameFocused = true
            }
        }
        .fullScreenCover(item: $activeEnemy) { enemy in
            PollutionBattleDialogueView(enemy: enemy) {
                purifyEnemy(id: enemy.id)
                activeEnemy = nil
                isGameFocused = true
            }
        }
        .sheet(isPresented: $showFieldGuide) {
            FieldGuideView(curriculum: curriculum)
        }
    }

    private var topHUD: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("GeoPaws: Open World")
                    .font(.headline.bold())
                    .foregroundColor(.white)
                Text(currentZone)
                    .font(.caption.bold())
                    .foregroundColor(.yellow)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "globe.asia.australia.fill").foregroundColor(.green)
                Text("\(curriculum.completedCount)/\(curriculum.totalCount)")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())

            Button {
                SoundManager.shared.play(.meow)
                showFieldGuide = true
            } label: {
                Label("Field Guide", systemImage: "book.fill")
                    .font(.subheadline.bold())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
    }

    private var bottomControls: some View {
        HStack(alignment: .bottom) {
            VirtualJoystick { vector in
                scene.movementVector = vector
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 8) {
                Text("Hold WASD or Arrow Keys")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.black.opacity(0.45), in: Capsule())

                Button {
                    scene.triggerMeowPulse()
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "pawprint.fill")
                            .font(.title2)
                        Text("PULSE")
                            .font(.caption2.bold())
                    }
                    .frame(width: 84, height: 84)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .shadow(radius: 6)
                }
            }
        }
    }

    private func handleKeyPress(_ press: KeyPress) {
        if press.phase == .down {
            pressedKeys.insert(press.key)
        } else if press.phase == .up {
            pressedKeys.remove(press.key)
        }

        var dx: CGFloat = 0; var dy: CGFloat = 0
        if pressedKeys.contains("w") || pressedKeys.contains(.upArrow) { dy += 1 }
        if pressedKeys.contains("s") || pressedKeys.contains(.downArrow) { dy -= 1 }
        if pressedKeys.contains("a") || pressedKeys.contains(.leftArrow) { dx -= 1 }
        if pressedKeys.contains("d") || pressedKeys.contains(.rightArrow) { dx += 1 }

        let length = hypot(dx, dy)
        scene.movementVector = length > 0 ? CGVector(dx: dx / length, dy: dy / length) : .zero
    }

    private func completeQuest(id: String) {
        if let idx = curriculum.quests.firstIndex(where: { $0.id == id }) {
            curriculum.quests[idx].isCompleted = true
            SoundManager.shared.play(.questComplete)
            scene.spawnEntities()
        }
    }

    private func purifyEnemy(id: String) {
        if let idx = curriculum.enemies.firstIndex(where: { $0.id == id }) {
            curriculum.enemies[idx].isPurified = true
            SoundManager.shared.play(.purify)
            scene.spawnEntities()
        }
    }

    class SceneCoordinator: OpenWorldDelegate {
        var parent: GeoWorldView?
        func didApproachQuest(_ quest: GeoQuest) { DispatchQueue.main.async { self.parent?.activeQuest = quest } }
        func didApproachEnemy(_ enemy: PollutionEnemy) { DispatchQueue.main.async { self.parent?.activeEnemy = enemy } }
        func didUpdateZone(_ zoneName: String) { DispatchQueue.main.async { self.parent?.currentZone = zoneName } }
    }
}

struct VirtualJoystick: View {
    var onMove: (CGVector) -> Void
    @State private var knobOffset: CGSize = .zero
    private let maxRadius: CGFloat = 42

    var body: some View {
        ZStack {
            Circle().fill(.ultraThinMaterial).frame(width: 110, height: 110)
                .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 2))
            Circle().fill(Color.white.opacity(0.85)).frame(width: 44, height: 44)
                .offset(knobOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let dx = value.translation.width; let dy = value.translation.height
                            let dist = hypot(dx, dy)
                            if dist <= maxRadius { knobOffset = value.translation }
                            else {
                                let angle = atan2(dy, dx)
                                knobOffset = CGSize(width: cos(angle) * maxRadius, height: sin(angle) * maxRadius)
                            }
                            onMove(CGVector(dx: knobOffset.width / maxRadius, dy: -knobOffset.height / maxRadius))
                        }
                        .onEnded { _ in
                            withAnimation(.spring()) { knobOffset = .zero }
                            onMove(.zero)
                        }
                )
        }
    }
}

struct CharacterDialogueView: View {
    let quest: GeoQuest
    var onComplete: () -> Void
    @Environment(\.dismiss) var dismiss

    @State private var selectedOption: Int?
    @State private var isCorrect = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.14, green: 0.16, blue: 0.35), .black], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 14) {
                HStack {
                    Button("Leave") { dismiss() }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                    Spacer()
                    Text(quest.zoneName).font(.headline).foregroundColor(.yellow)
                }
                .padding(.horizontal)
                .padding(.top, 8)

                ZStack(alignment: .bottom) {
                    GeographyStageBackdrop(questId: quest.id, isSolved: isCorrect || quest.isCompleted)

                    ShapeCatView(
                        bodyColor: catColor(for: quest.npcShapeColor),
                        size: 92,
                        isMayor: quest.id == "hierarchy"
                    )
                }

                Text(quest.npcName).font(.title3.bold()).foregroundColor(.white)

                Text("\"\(isCorrect ? quest.question.explanation : quest.storyText)\"")
                    .font(.subheadline).italic()
                    .multilineTextAlignment(.center)
                    .padding(12)
                    .background(isCorrect ? Color.green.opacity(0.25) : Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
                    .foregroundColor(.white)
                    .padding(.horizontal)

                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Field Notes").font(.headline).foregroundColor(.yellow)
                        ForEach(quest.fieldNotes, id: \.self) { note in
                            Text(note).font(.caption).foregroundColor(.white.opacity(0.9))
                        }

                        Divider().background(.white.opacity(0.4))

                        Text("Challenge: \(quest.question.prompt)").font(.subheadline.bold()).foregroundColor(.white)

                        ForEach(0..<quest.question.options.count, id: \.self) { idx in
                            Button {
                                selectedOption = idx
                                if idx == quest.question.correctIndex {
                                    withAnimation(.spring()) { isCorrect = true }
                                    SoundManager.shared.play(.quizCorrect)
                                } else {
                                    isCorrect = false
                                    SoundManager.shared.play(.quizWrong)
                                }
                            } label: {
                                HStack {
                                    Text(quest.question.options[idx]).font(.subheadline).multilineTextAlignment(.leading)
                                    Spacer()
                                    if selectedOption == idx {
                                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    }
                                }
                                .padding(12)
                                .background(selectedOption == idx ? (isCorrect ? Color.green : Color.red).opacity(0.45) : Color.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 10))
                                .foregroundColor(.white)
                            }
                        }

                        if isCorrect {
                            Button("Complete Quest & Return to World") {
                                onComplete()
                                dismiss()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 6)
                        }
                    }
                    .padding()
                    .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)
                }
            }
        }
    }

    private func catColor(for name: String) -> Color {
        switch name {
        case "orange": return .orange
        case "purple": return .purple
        case "cyan": return .cyan
        case "green": return .mint
        case "blue": return .blue
        default: return .pink
        }
    }
}

struct PollutionBattleDialogueView: View {
    let enemy: PollutionEnemy
    var onPurify: () -> Void
    @Environment(\.dismiss) var dismiss

    @State private var selectedOption: Int?
    @State private var defeated = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [.purple, .black], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                HStack {
                    Button("Flee") { dismiss() }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                    Spacer()
                    Text(enemy.pollutionType).font(.headline).foregroundColor(.pink)
                }
                .padding(.horizontal)
                .padding(.top, 8)

                VStack(spacing: 10) {
                    ShapeMonsterView(size: 90, isDefeated: defeated)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: defeated)

                    Text(enemy.name).font(.title3.bold()).foregroundColor(.white)

                    Text(defeated ? "Slime purified! Nature is healing." : enemy.topicLesson)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(12)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Defeat the Pollution:").font(.headline).foregroundColor(.yellow)
                        Text(enemy.question.prompt).font(.subheadline.bold()).foregroundColor(.white)

                        ForEach(0..<enemy.question.options.count, id: \.self) { idx in
                            Button {
                                selectedOption = idx
                                if idx == enemy.question.correctIndex {
                                    defeated = true
                                    SoundManager.shared.play(.quizCorrect)
                                } else {
                                    SoundManager.shared.play(.quizWrong)
                                }
                            } label: {
                                HStack {
                                    Text(enemy.question.options[idx]).font(.subheadline)
                                    Spacer()
                                }
                                .padding(12)
                                .background(selectedOption == idx ? (defeated ? Color.green : Color.red).opacity(0.45) : Color.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 10))
                                .foregroundColor(.white)
                            }
                        }

                        if defeated {
                            Button("Purify Area & Restore Nature!") {
                                onPurify()
                                dismiss()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.purple)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 6)
                        }
                    }
                    .padding()
                    .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct FieldGuideView: View {
    @ObservedObject var curriculum: GeographyCurriculum
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Settlements, Services & Sustainability") {
                    ForEach(curriculum.quests) { quest in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(quest.topic).font(.headline)
                                Spacer()
                                Text(quest.isCompleted ? "Mastered" : quest.zoneName)
                                    .font(.caption.bold())
                                    .foregroundColor(quest.isCompleted ? .green : .secondary)
                            }
                            ForEach(quest.fieldNotes, id: \.self) { note in
                                Text(note).font(.caption).foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Cat's Geography Guide")
            .toolbar { Button("Done") { dismiss() } }
        }
    }
}
