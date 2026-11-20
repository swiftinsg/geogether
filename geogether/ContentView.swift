import SwiftUI
import SpriteKit

struct ContentView: View {
    @StateObject private var curriculum = GeographyCurriculum()
    @State private var scene = OpenWorldScene(size: CGSize(width: 1000, height: 800))
    @State private var coordinator = SceneCoordinator()
    
    @State private var activeQuest: GeoQuest?
    @State private var activeEnemy: PollutionEnemy?
    @State private var showFieldGuide = false
    @State private var showInstructions = true
    @State private var showQuickStudy = false
    @State private var currentZone = "Central Crossroads"
    @State private var playerPosition: CGPoint = .zero
    
    @State private var pressedKeys: Set<KeyEquivalent> = []
    @FocusState private var isGameFocused: Bool
    
    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .ignoresSafeArea()
                .focusable()
                .focused($isGameFocused)
                .onKeyPress(phases: [.down, .up]) { press in
                    guard !showInstructions else { return .ignored }
                    handleKeyPress(press)
                    return .handled
                }
            
            VStack {
                topHUD
                Spacer()
                bottomControls
            }
            .padding()
            
            if showInstructions {
                HowToPlayOverlayView {
                    withAnimation(.spring()) {
                        showInstructions = false
                        isGameFocused = true
                    }
                    SoundManager.shared.play(.meow)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .zIndex(50)
            }
        }
        .onAppear {
            scene.scaleMode = .resizeFill
            scene.curriculum = curriculum
            coordinator.parent = self
            scene.worldDelegate = coordinator
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
        .sheet(isPresented: $showQuickStudy) {
            QuickStudySessionView(curriculum: curriculum)
        }
    }
    
    private var topHUD: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
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
                
                HStack(spacing: 8) {
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
                        Label("Guide", systemImage: "book.fill")
                            .font(.subheadline.bold())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    
                    Button {
                        withAnimation(.spring()) { showInstructions = true }
                    } label: {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.title3)
                            .padding(6)
                            .background(.ultraThinMaterial, in: Circle())
                            .foregroundColor(.white)
                    }
                }
            }
            
            Spacer()
            
            MiniMapView(
                playerPosition: playerPosition,
                quests: curriculum.quests,
                enemies: curriculum.enemies
            )
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
                    SoundManager.shared.play(.meow)
                    showQuickStudy = true
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "book.closed.fill")
                            .font(.title2)
                        Text("QUICK STUDY")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .frame(width: 84, height: 84)
                    .background(Color.indigo)
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
        var parent: ContentView?
        func didApproachQuest(_ quest: GeoQuest) { DispatchQueue.main.async { self.parent?.activeQuest = quest } }
        func didApproachEnemy(_ enemy: PollutionEnemy) { DispatchQueue.main.async { self.parent?.activeEnemy = enemy } }
        func didUpdateZone(_ zoneName: String) { DispatchQueue.main.async { self.parent?.currentZone = zoneName } }
        func didUpdatePlayerPosition(_ position: CGPoint) { DispatchQueue.main.async { self.parent?.playerPosition = position } }
    }
}

// MARK: - Quick Study Session View
struct QuickStudySessionView: View {
    @ObservedObject var curriculum: GeographyCurriculum
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTopic: String = "All Topics"
    @State private var currentIndex = 0
    @State private var userAnswer = ""
    @State private var showAnswer = false
    @State private var isAnswerChecked = false
    
    struct StudyItem: Identifiable {
        let id = UUID()
        let topic: String
        let prompt: String
        let correctOptionText: String
        let explanation: String
    }
    
    var allItems: [StudyItem] {
        let questItems = curriculum.quests.map { StudyItem(topic: $0.topic, prompt: $0.question.prompt, correctOptionText: $0.question.options[$0.question.correctIndex], explanation: $0.question.explanation) }
        let enemyItems = curriculum.enemies.map { StudyItem(topic: $0.pollutionType, prompt: $0.question.prompt, correctOptionText: $0.question.options[$0.question.correctIndex], explanation: $0.question.explanation) }
        return questItems + enemyItems
    }
    
    var availableTopics: [String] {
        ["All Topics"] + Array(Set(allItems.map { $0.topic })).sorted()
    }
    
    var filteredItems: [StudyItem] {
        if selectedTopic == "All Topics" { return allItems }
        return allItems.filter { $0.topic == selectedTopic }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(red: 0.1, green: 0.12, blue: 0.25), .black], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack(spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Select Study Topic:")
                            .font(.caption.bold())
                            .foregroundColor(.yellow)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(availableTopics, id: \.self) { topic in
                                    Button {
                                        selectedTopic = topic
                                        currentIndex = 0
                                        userAnswer = ""
                                        showAnswer = false
                                        isAnswerChecked = false
                                    } label: {
                                        Text(topic)
                                            .font(.caption.bold())
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(selectedTopic == topic ? Color.indigo : Color.white.opacity(0.15))
                                            .foregroundColor(.white)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    if filteredItems.isEmpty {
                        Spacer()
                        Text("No questions found for this topic.").foregroundColor(.secondary)
                        Spacer()
                    } else {
                        let item = filteredItems[currentIndex % filteredItems.count]
                        
                        HStack {
                            Text("Topic: \(item.topic)")
                                .font(.caption.bold()).foregroundColor(.cyan)
                            Spacer()
                            Text("Question \((currentIndex % filteredItems.count) + 1) of \(filteredItems.count)")
                                .font(.caption.bold()).foregroundColor(.yellow)
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Prompt:")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                            Text(item.prompt)
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Answer (Open-Ended):")
                                .font(.caption.bold())
                                .foregroundColor(.white.opacity(0.8))
                            
                            TextField("Type your answer here...", text: $userAnswer)
                                .textFieldStyle(.roundedBorder)
                                .foregroundColor(.black)
                            
                            HStack(spacing: 10) {
                                Button("Check Answer") {
                                    isAnswerChecked = true
                                    showAnswer = true
                                    SoundManager.shared.play(.quizCorrect)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.green)
                                
                                Button("Reveal Answer") {
                                    showAnswer = true
                                }
                                .buttonStyle(.bordered)
                                .tint(.yellow)
                                
                                Spacer()
                                
                                Button("Next Question") {
                                    currentIndex += 1
                                    userAnswer = ""
                                    showAnswer = false
                                    isAnswerChecked = false
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.indigo)
                            }
                            .padding(.top, 4)
                        }
                        .padding()
                        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                        
                        if showAnswer {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Key Concept Answer:")
                                        .font(.caption.bold())
                                        .foregroundColor(.yellow)
                                    Text(item.correctOptionText)
                                        .font(.subheadline.bold())
                                        .foregroundColor(.white)
                                    
                                    Divider().background(.white.opacity(0.3))
                                    
                                    Text("Detailed Explanation:")
                                        .font(.caption.bold())
                                        .foregroundColor(.green)
                                    Text(item.explanation)
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                .padding()
                                .background(Color.black.opacity(0.6), in: RoundedRectangle(cornerRadius: 16))
                                .padding(.horizontal)
                            }
                        }
                        
                        Spacer()
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Quick Study Mode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.foregroundColor(.yellow).bold()
                }
            }
        }
    }
}

// MARK: - Mini-Map Radar
struct MiniMapView: View {
    let playerPosition: CGPoint
    let quests: [GeoQuest]
    let enemies: [PollutionEnemy]
    
    private let mapWidth: CGFloat = 140
    private let mapHeight: CGFloat = 120
    private let worldWidth: CGFloat = 1500
    private let worldHeight: CGFloat = 1300
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                VStack(spacing: 1) {
                    HStack(spacing: 1) {
                        Color(red: 0.22, green: 0.48, blue: 0.22)
                        Color(red: 0.23, green: 0.26, blue: 0.32)
                    }
                    HStack(spacing: 1) {
                        Color(red: 0.18, green: 0.40, blue: 0.30)
                        Color(red: 0.08, green: 0.32, blue: 0.38)
                    }
                }
                .frame(width: mapWidth, height: mapHeight)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Rectangle().fill(Color.white.opacity(0.25)).frame(width: mapWidth, height: 2)
                Rectangle().fill(Color.white.opacity(0.25)).frame(width: 2, height: mapHeight)
                
                ForEach(quests) { quest in
                    Circle()
                        .fill(quest.isCompleted ? Color.green : Color.cyan)
                        .frame(width: 7, height: 7)
                        .position(convertToMiniMap(quest.position))
                }
                
                ForEach(enemies) { enemy in
                    if !enemy.isPurified {
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(Color.purple)
                            .overlay(RoundedRectangle(cornerRadius: 1.5).stroke(Color.pink, lineWidth: 1))
                            .frame(width: 7, height: 7)
                            .position(convertToMiniMap(enemy.position))
                    }
                }
                
                Circle()
                    .fill(Color.orange)
                    .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                    .frame(width: 9, height: 9)
                    .position(convertToMiniMap(playerPosition))
            }
            .frame(width: mapWidth, height: mapHeight)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.45), lineWidth: 2))
            .shadow(radius: 4)
            
            HStack(spacing: 8) {
                legendDot(color: .orange, text: "You")
                legendDot(color: .cyan, text: "Quest")
                legendDot(color: .purple, text: "Slime")
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(.black.opacity(0.55), in: Capsule())
        }
    }
    
    private func convertToMiniMap(_ pos: CGPoint) -> CGPoint {
        let normX = (pos.x + worldWidth / 2) / worldWidth
        let normY = 1.0 - ((pos.y + worldHeight / 2) / worldHeight)
        return CGPoint(
            x: max(6, min(mapWidth - 6, normX * mapWidth)),
            y: max(6, min(mapHeight - 6, normY * mapHeight))
        )
    }
    
    private func legendDot(color: Color, text: String) -> some View {
        HStack(spacing: 3) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(text).font(.system(size: 9, weight: .bold)).foregroundColor(.white)
        }
    }
}

// MARK: - Pre-Game Instructions Overlay
struct HowToPlayOverlayView: View {
    var onStart: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.75).ignoresSafeArea()
            
            VStack(spacing: 20) {
                ShapeCatView(bodyColor: .orange, size: 75, isMayor: false)
                
                Text("Welcome to GeoPaws!")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                Text("Explore biomes, launch professional interactive models with NPC cats, and study key geography concepts using Quick Study mode!")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.85))
                
                VStack(alignment: .leading, spacing: 14) {
                    instructionRow(icon: "gamecontroller.fill", color: .orange, title: "Move Your Cat", detail: "Hold WASD, Arrow Keys, or drag the bottom-left joystick.")
                    instructionRow(icon: "book.closed.fill", color: .indigo, title: "Quick Study Mode", detail: "Tap the bottom-left Quick Study button to practice open-ended questions by topic.")
                    instructionRow(icon: "play.rectangle.fill", color: .green, title: "Professional Simulations", detail: "Click 'Simulation Model' in dialogue for professional interactive geographic models.")
                }
                .padding()
                .background(Color.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
                
                Button {
                    onStart()
                } label: {
                    Text("Start Exploring")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.green, in: RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(24)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.25), lineWidth: 1.5))
            .frame(maxWidth: 440)
            .padding()
        }
    }
    
    private func instructionRow(icon: String, color: Color, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon).font(.title3).foregroundColor(color).frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.bold()).foregroundColor(.white)
                Text(detail).font(.caption).foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

// MARK: - Virtual Joystick
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

// MARK: - Interactive Dialogue View
struct CharacterDialogueView: View {
    let quest: GeoQuest
    var onComplete: () -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedOption: Int?
    @State private var isCorrect = false
    @State private var showSimulation = false
    
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
                    ShapeCatView(bodyColor: catColor(for: quest.npcShapeColor), size: 92, isMayor: quest.id == "hierarchy")
                }
                
                HStack(spacing: 12) {
                    Text(quest.npcName).font(.title3.bold()).foregroundColor(.white)
                    
                    Button {
                        showSimulation = true
                    } label: {
                        Label("Simulation Model", systemImage: "play.circle.fill")
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
                
                Text("\"\(selectedOption != nil ? quest.question.explanation : quest.storyText)\"")
                    .font(.subheadline).italic()
                    .multilineTextAlignment(.center)
                    .padding(12)
                    .background(selectedOption != nil ? (isCorrect ? Color.green.opacity(0.25) : Color.orange.opacity(0.25)) : Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
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
        .sheet(isPresented: $showSimulation) {
            InteractiveSimulationView(questId: quest.id, topicTitle: quest.topic)
        }
    }
    
    private func catColor(for name: String) -> Color {
        switch name {
        case "orange": return .orange
        case "purple": return .purple
        case "cyan": return .cyan
        case "green": return .mint
        case "blue": return .blue
        case "yellow": return .yellow
        case "mint": return .mint
        case "indigo": return .indigo
        default: return .pink
        }
    }
}

// MARK: - Professional Interactive Simulation Models
struct InteractiveSimulationView: View {
    let questId: String
    let topicTitle: String
    @Environment(\.dismiss) var dismiss
    
    @State private var sliderVal: Double = 50.0
    @State private var toggleState: Bool = false
    @State private var stepIndex: Int = 1
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(red: 0.08, green: 0.1, blue: 0.18), Color.black], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text("PROFESSIONAL GEOGRAPHY SIMULATOR")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.yellow)
                        Text(topicTitle)
                            .font(.title3.bold())
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.06))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.15), lineWidth: 1))
                            .frame(height: 230)
                        
                        simVisualContent
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 14) {
                        simControlsView
                    }
                    .padding(16)
                    .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.12), lineWidth: 1))
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.foregroundColor(.yellow).bold()
                }
            }
        }
    }
    
    @ViewBuilder
    private var simVisualContent: some View {
        switch questId {
        case "patterns":
            VStack(spacing: 14) {
                HStack(spacing: Int(sliderVal) < 35 ? 28 : (Int(sliderVal) < 70 ? 10: 4)) {
                    ForEach(0..<(Int(sliderVal) < 35 ? 3 : (Int(sliderVal) < 70 ? 6 : 10)), id: \.self) { _ in
                        VStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Int(sliderVal) < 35 ? Color.orange : (Int(sliderVal) < 70 ? Color.cyan : Color.green))
                                .frame(width: 20, height: 26)
                            Circle().fill(Color.white.opacity(0.5)).frame(width: 4, height: 4)
                        }
                    }
                }
                VStack(spacing: 4) {
                    Text(Int(sliderVal) < 35 ? "Model: Dispersed Settlement" : (Int(sliderVal) < 70 ? "Model: Linear Settlement (Road/River Axis)" : "Model: Nucleated Settlement (Market Crossroads)"))
                        .font(.caption.bold()).foregroundColor(.white)
                    Text("Spatial Distribution Index: \(Int(sliderVal))%")
                        .font(.system(size: 10)).foregroundColor(.secondary)
                }
            }
            
        case "hierarchy":
            // Population & Building Scale Simulation
            VStack(spacing: 12) {
                let buildingCount = stepIndex == 1 ? 1 : (stepIndex == 3 ? 4 : (stepIndex == 5 ? 9 : 16))
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 28))], spacing: 8) {
                    ForEach(0..<buildingCount, id: \.self) { _ in
                        VStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(stepIndex >= 7 ? Color.indigo : (stepIndex >= 5 ? Color.blue : (stepIndex >= 3 ? Color.cyan : Color.orange)))
                                .frame(width: 22, height: 26)
                            Circle().fill(Color.white.opacity(0.5)).frame(width: 3, height: 3)
                        }
                    }
                }
                .frame(maxHeight: 130)
                .padding(.horizontal)
                
                Text("Tier \(stepIndex): \(hierarchyLevelName(stepIndex)) — Population: \(hierarchyPopulation(stepIndex))")
                    .font(.caption.bold()).foregroundColor(.yellow)
            }
            
        case "services":
            ZStack {
                Circle().fill(Color.blue.opacity(toggleState ? 0.3 : 0.15)).frame(width: toggleState ? 200 : 90)
                    .overlay(Circle().stroke(toggleState ? Color.blue : Color.cyan, lineWidth: 1.5))
                VStack(spacing: 4) {
                    Circle().fill(Color.cyan).frame(width: 28, height: 28)
                    Text(toggleState ? "Specialist Hospital (High-Order Goods)" : "Convenience Milk Shop (Low-Order Goods)")
                        .font(.caption.bold()).foregroundColor(.white)
                }
                .offset(y: 75)
            }
            
        case "rural_urban":
            HStack(spacing: 30) {
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 4).fill(Color.mint).frame(width: 45, height: CGFloat(30 + sliderVal * 0.4))
                    Text("Rural Primary\nSector Land").font(.system(size: 10, weight: .bold)).foregroundColor(.mint).multilineTextAlignment(.center)
                }
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 4).fill(Color.gray).frame(width: 55, height: CGFloat(60 + (100 - sliderVal) * 1.1))
                    Text("Urban Vertical\nHigh-Rise Density").font(.system(size: 10, weight: .bold)).foregroundColor(.gray).multilineTextAlignment(.center)
                }
            }
            
        case "mangroves":
            VStack(spacing: 10) {
                HStack(spacing: 30) {
                    VStack(spacing: 4) {
                        Text("Prop Roots").font(.system(size: 10, weight: .bold)).foregroundColor(.cyan)
                        Capsule().fill(Color.brown).frame(width: 12, height: 65)
                    }
                    VStack(spacing: 4) {
                        Text("Pneumatophores").font(.system(size: 10, weight: .bold)).foregroundColor(.cyan)
                        HStack(spacing: 4) {
                            Rectangle().fill(Color.brown).frame(width: 5, height: CGFloat(22 + sliderVal * 0.35))
                            Rectangle().fill(Color.brown).frame(width: 5, height: CGFloat(16 + sliderVal * 0.25))
                        }
                    }
                }
                Rectangle().fill(Color.blue.opacity(0.65)).frame(height: CGFloat(35 + sliderVal * 0.85))
            }
            
        case "housing":
            VStack(spacing: 10) {
                HStack(spacing: 18) {
                    RoundedRectangle(cornerRadius: 8).fill(toggleState ? Color.green : Color.brown).frame(width: 50, height: 75)
                        .overlay(VStack {
                            if toggleState { Image(systemName: "sun.max.fill").foregroundColor(.yellow).font(.caption) }
                        })
                    VStack(alignment: .leading, spacing: 4) {
                        Text(toggleState ? "Environmental Pillar: Solar & Rainwater Active" : "Conventional Grid Energy Dependency")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(toggleState ? .green : .orange)
                        Text(toggleState ? "Carbon Emissions: -65% | Cost: Low" : "Carbon Emissions: High | Cost: High")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
        case "microclimate":
            HStack(spacing: 30) {
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 6).fill(toggleState ? Color.green : Color.red).frame(width: 50, height: toggleState ? 95 : 130)
                    Text(toggleState ? "Cooled Urban Canopy" : "Urban Heat Island Trap").font(.system(size: 10, weight: .bold)).foregroundColor(toggleState ? .green : .red).multilineTextAlignment(.center)
                }
                VStack(spacing: 6) {
                    Circle().fill(toggleState ? Color.mint : Color.orange).frame(width: 50, height: 50)
                    Text(toggleState ? "Albedo Balanced" : "High Radiation Absorption").font(.system(size: 10)).foregroundColor(.white).multilineTextAlignment(.center)
                }
            }
            
        case "migration":
            HStack(spacing: 25) {
                VStack(spacing: 4) {
                    Text("Rural Push").font(.caption2).foregroundColor(.secondary)
                    Rectangle().fill(Color.brown).frame(width: 35, height: CGFloat(30 + sliderVal * 0.5))
                }
                Image(systemName: "arrow.right.circle.fill").font(.title2).foregroundColor(.yellow)
                VStack(spacing: 4) {
                    Text("Urban Pull").font(.caption2).foregroundColor(.secondary)
                    Rectangle().fill(Color.cyan).frame(width: 35, height: CGFloat(75 + (100 - sliderVal) * 0.45))
                }
            }
            
        case "food_miles":
            VStack(spacing: 8) {
                Image(systemName: sliderVal > 50 ? "airplane.circle.fill" : "leaf.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(sliderVal > 50 ? .red : .green)
                Text("Supply Chain Distance: \(Int(sliderVal * 40)) food miles")
                    .font(.subheadline.bold()).foregroundColor(.white)
                Text(sliderVal > 50 ? "High transport fossil fuel emissions" : "Local sustainable sourcing footprint")
                    .font(.caption).foregroundColor(sliderVal > 50 ? .pink : .green)
            }
            
        default:
            VStack(spacing: 6) {
                Image(systemName: "globe.americas.fill").font(.system(size: 50)).foregroundColor(.cyan)
                Text("Geographic Model Active").font(.headline).foregroundColor(.white)
            }
        }
    }
    
    @ViewBuilder
    private var simControlsView: some View {
        switch questId {
        case "patterns":
            Text("Spatial Distribution Parameter: \(Int(sliderVal))%").font(.subheadline.bold()).foregroundColor(.white)
            Slider(value: $sliderVal, in: 0...100).tint(.cyan)
            Text("Adjust parameter to model Dispersed, Linear, and Nucleated settlement typologies.").font(.caption2).foregroundColor(.secondary).multilineTextAlignment(.center)
            
        case "hierarchy":
            Text("Hierarchy Tier Stage: Level \(stepIndex)").font(.subheadline.bold()).foregroundColor(.white)
            Button(stepIndex < 7 ? "Scale Up Hierarchy Tier ↑" : "Reset Hierarchy") {
                stepIndex = stepIndex < 7 ? stepIndex + 2 : 1
            }
            .buttonStyle(.borderedProminent).tint(.purple)
            Text("Examine progressive scaling from isolated rural dwellings to metropolitan conurbations by tracking population growth.").font(.caption2).foregroundColor(.secondary).multilineTextAlignment(.center)
            
        case "services":
            Text(toggleState ? "Service Active: Specialist Regional Hospital" : "Service Active: Local Convenience Shop")
                .font(.subheadline.bold()).foregroundColor(.cyan)
            Button(toggleState ? "Switch to Low-Order Service" : "Switch to High-Order Service") {
                toggleState.toggle()
            }
            .buttonStyle(.borderedProminent).tint(.blue)
            Text("Demonstrates threshold population requirements and proportional spheres of influence.").font(.caption2).foregroundColor(.secondary).multilineTextAlignment(.center)
            
        case "rural_urban":
            Text("Economic Land Allocation: \(Int(sliderVal))%").font(.subheadline.bold()).foregroundColor(.white)
            Slider(value: $sliderVal, in: 0...100).tint(.mint)
            Text("Contrasts rural primary sector resource usage with urban secondary/tertiary land density.").font(.caption2).foregroundColor(.secondary).multilineTextAlignment(.center)
            
        case "mangroves":
            Text("Tidal Water Amplitude: \(Int(sliderVal))%").font(.subheadline.bold()).foregroundColor(.white)
            Slider(value: $sliderVal, in: 0...100).tint(.cyan)
            Text("Simulates anaerobic mud saturation and root adaptation mechanics across tidal cycles.").font(.caption2).foregroundColor(.secondary).multilineTextAlignment(.center)
            
        case "housing":
            Text(toggleState ? "Eco-Housing Architecture Active" : "Standard Fossil-Fuel Architecture")
                .font(.subheadline.bold()).foregroundColor(toggleState ? .green : .orange)
            Button(toggleState ? "Revert to Standard Build" : "Deploy Solar & Rainwater Systems") {
                toggleState.toggle()
            }
            .buttonStyle(.borderedProminent).tint(toggleState ? .red : .green)
            Text("Integrates environmental sustainability standards with long-term economic efficiency.").font(.caption2).foregroundColor(.secondary).multilineTextAlignment(.center)
            
        case "microclimate":
            Text(toggleState ? "Mitigation: Urban Forestry Active" : "Baseline: Concrete Heat Island")
                .font(.subheadline.bold()).foregroundColor(toggleState ? .green : .red)
            Button(toggleState ? "Remove Green Infrastructure" : "Deploy Green Roofs & Canopy") {
                toggleState.toggle()
            }
            .buttonStyle(.borderedProminent).tint(toggleState ? .red : .green)
            Text("Evaluates microclimate cooling capacity via albedo management and urban greening.").font(.caption2).foregroundColor(.secondary).multilineTextAlignment(.center)
            
        case "migration":
            Text("Push/Pull Force Index: \(Int(sliderVal))%").font(.subheadline.bold()).foregroundColor(.white)
            Slider(value: $sliderVal, in: 0...100).tint(.yellow)
            Text("Quantifies rural economic push pressures against urban pull magnets.").font(.caption2).foregroundColor(.secondary).multilineTextAlignment(.center)
            
        case "food_miles":
            Text("Supply Chain Distance: \(Int(sliderVal * 40)) miles").font(.subheadline.bold()).foregroundColor(.white)
            Slider(value: $sliderVal, in: 0...100).tint(.indigo)
            Text("Calculates carbon emissions generated across agricultural transport networks.").font(.caption2).foregroundColor(.secondary).multilineTextAlignment(.center)
            
        default:
            Text("Geographic Model Inspector").font(.subheadline.bold()).foregroundColor(.white)
            Text("Inspect dynamic spatial variables in real time.").font(.caption2).foregroundColor(.secondary).multilineTextAlignment(.center)
        }
    }
    
    private func hierarchyLevelName(_ level: Int) -> String {
        switch level {
        case 1: return "Isolated Dwelling"
        case 3: return "Village / Hamlet"
        case 5: return "Large Town / City"
        default: return "Conurbation Metropolis"
        }
    }
    
    private func hierarchyPopulation(_ level: Int) -> String {
        switch level {
        case 1: return "1–10 residents"
        case 3: return "500–5,000 residents"
        case 5: return "100,000–1,000,000 residents"
        default: return "5,000,000+ residents"
        }
    }
}

// MARK: - Pollution Battle Dialogue View
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
                    
                    Text(selectedOption != nil ? enemy.question.explanation : enemy.topicLesson)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(12)
                        .background(selectedOption != nil ? (defeated ? Color.green.opacity(0.25) : Color.orange.opacity(0.25)) : Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
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
                                    defeated = false
                                    SoundManager.shared.play(.quizWrong)
                                }
                            } label: {
                                HStack {
                                    Text(enemy.question.options[idx]).font(.subheadline)
                                    Spacer()
                                    if selectedOption == idx {
                                        Image(systemName: defeated ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    }
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

// MARK: - Field Guide View
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
