import SpriteKit
import SwiftUI

struct GeoWorldView: View {
    @StateObject private var curriculum = GeographyCurriculum()

    @State private var scene = OpenWorldScene(size: CGSize(width: 1000, height: 800))
    @State private var coordinator = SceneCoordinator()
    @State private var activeQuest: GeoQuest?
    @State private var activeEnemy: PollutionEnemy?
    @State private var showFieldGuide = false
    @State private var showInstructions = true
    @State private var showQuickStudy = false
    @State private var showSimulationPicker = false
    @State private var currentZone = "Central Crossroads"
    @State private var playerPosition = CGPoint.zero
    @State private var pressedKeys: Set<KeyEquivalent> = []
    @State private var movementResetID = 0

    @FocusState private var isGameFocused: Bool

    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .ignoresSafeArea()
                .focusable()
                .focused($isGameFocused)
                .onKeyPress(phases: [.down, .up], action: handleKeyPress)

            VStack {
                GameHUDView(
                    zoneName: currentZone,
                    playerLevel: curriculum.playerLevel,
                    completedCount: curriculum.completedCount,
                    totalCount: curriculum.totalCount,
                    playerPosition: playerPosition,
                    quests: curriculum.quests,
                    enemies: curriculum.enemies,
                    openGuide: openGuide,
                    openInstructions: openInstructions
                )

                Spacer()

                GameControlsView(
                    onMove: movePlayer,
                    openSimulations: openSimulations,
                    openQuickStudy: openQuickStudy,
                    movementResetID: movementResetID,
                    isMovementEnabled: canMovePlayer
                )
            }
            .padding()

            if showInstructions {
                HowToPlayOverlayView(startGame: startGame)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    .zIndex(50)
            }
        }
        .onAppear(perform: configureScene)
        .fullScreenCover(item: $activeQuest, onDismiss: restoreGameFocus) { quest in
            CharacterDialogueView(
                quest: quest,
                currentLevel: curriculum.playerLevel,
                canLevelUp: !quest.isCompleted,
                levelUp: { completeQuest(id: quest.id) }
            )
        }
        .fullScreenCover(item: $activeEnemy, onDismiss: restoreGameFocus) { enemy in
            PollutionBattleDialogueView(enemy: enemy) {
                purifyEnemy(id: enemy.id)
            }
        }
        .sheet(isPresented: $showFieldGuide, onDismiss: restoreGameFocus) {
            FieldGuideView(curriculum: curriculum)
        }
        .sheet(isPresented: $showQuickStudy, onDismiss: restoreGameFocus) {
            QuickStudySessionView(curriculum: curriculum)
        }
        .sheet(isPresented: $showSimulationPicker, onDismiss: restoreGameFocus) {
            GameSimulationPickerView()
        }
    }

    private func configureScene() {
        scene.scaleMode = .resizeFill
        scene.curriculum = curriculum
        coordinator.parent = self
        scene.worldDelegate = coordinator
    }

    private func handleKeyPress(_ press: KeyPress) -> KeyPress.Result {
        guard canMovePlayer else { return .ignored }

        if press.phase == .down {
            pressedKeys.insert(press.key)
        } else if press.phase == .up {
            pressedKeys.remove(press.key)
        }

        var dx: CGFloat = 0
        var dy: CGFloat = 0
        if pressedKeys.contains("w") || pressedKeys.contains(.upArrow) { dy += 1 }
        if pressedKeys.contains("s") || pressedKeys.contains(.downArrow) { dy -= 1 }
        if pressedKeys.contains("a") || pressedKeys.contains(.leftArrow) { dx -= 1 }
        if pressedKeys.contains("d") || pressedKeys.contains(.rightArrow) { dx += 1 }

        let length = hypot(dx, dy)
        scene.movementVector = length > 0 ? CGVector(dx: dx / length, dy: dy / length) : .zero
        return .handled
    }

    private func movePlayer(_ vector: CGVector) {
        guard canMovePlayer else {
            scene.movementVector = .zero
            return
        }
        scene.movementVector = vector
    }

    private var canMovePlayer: Bool {
        activeQuest == nil &&
            activeEnemy == nil &&
            !showInstructions &&
            !showFieldGuide &&
            !showQuickStudy &&
            !showSimulationPicker
    }

    private func stopPlayerMovement() {
        scene.movementVector = .zero
        pressedKeys.removeAll()
        movementResetID += 1
    }

    private func beginQuestEncounter(_ quest: GeoQuest) {
        stopPlayerMovement()
        activeQuest = quest
    }

    private func beginEnemyEncounter(_ enemy: PollutionEnemy) {
        stopPlayerMovement()
        activeEnemy = enemy
    }

    private func completeQuest(id: String) {
        guard curriculum.completeQuest(id: id) else { return }
        SoundManager.shared.play(.questComplete)
        scene.spawnEntities()
    }

    private func purifyEnemy(id: String) {
        guard curriculum.purifyEnemy(id: id) else { return }
        SoundManager.shared.play(.purify)
        scene.spawnEntities()
    }

    private func openGuide() {
        SoundManager.shared.play(.meow)
        showFieldGuide = true
    }

    private func openInstructions() {
        withAnimation(.spring()) {
            showInstructions = true
        }
    }

    private func openQuickStudy() {
        SoundManager.shared.play(.meow)
        showQuickStudy = true
    }

    private func openSimulations() {
        SoundManager.shared.play(.meow)
        showSimulationPicker = true
    }

    private func startGame() {
        withAnimation(.spring()) {
            showInstructions = false
        }
        SoundManager.shared.play(.meow)
        restoreGameFocus()
    }

    private func restoreGameFocus() {
        isGameFocused = true
    }

    final class SceneCoordinator: OpenWorldDelegate {
        var parent: GeoWorldView?

        func didApproachQuest(_ quest: GeoQuest) {
            DispatchQueue.main.async { self.parent?.beginQuestEncounter(quest) }
        }

        func didApproachEnemy(_ enemy: PollutionEnemy) {
            DispatchQueue.main.async { self.parent?.beginEnemyEncounter(enemy) }
        }

        func didUpdateZone(_ zoneName: String) {
            DispatchQueue.main.async { self.parent?.currentZone = zoneName }
        }

        func didUpdatePlayerPosition(_ position: CGPoint) {
            DispatchQueue.main.async { self.parent?.playerPosition = position }
        }
    }
}
