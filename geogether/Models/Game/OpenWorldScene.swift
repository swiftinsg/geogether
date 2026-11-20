import SpriteKit
import SwiftUI

protocol OpenWorldDelegate: AnyObject {
    func didApproachQuest(_ quest: GeoQuest)
    func didApproachEnemy(_ enemy: PollutionEnemy)
    func didUpdateZone(_ zoneName: String)
}

class OpenWorldScene: SKScene {
    weak var worldDelegate: OpenWorldDelegate?
    var curriculum: GeographyCurriculum? {
        didSet {
            if view != nil {
                spawnEntities()
            }
        }
    }

    private let catPlayer = SKNode()
    private let auraRing = SKShapeNode(circleOfRadius: 38)

    var movementVector: CGVector = .zero
    private let moveSpeed: CGFloat = 240.0
    private var lastStepTime: TimeInterval = 0
    private var cooldownTimer: TimeInterval = 0

    private let cam = SKCameraNode()

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.14, green: 0.32, blue: 0.19, alpha: 1.0)
        self.camera = cam
        addChild(cam)

        buildWorldBiomes()
        setupCatPlayer()
        spawnEntities()
    }

    private func buildWorldBiomes() {
        let border = SKShapeNode(rectOf: CGSize(width: 1500, height: 1300), cornerRadius: 20)
        border.strokeColor = .white.withAlphaComponent(0.35)
        border.lineWidth = 8
        addChild(border)

        addZoneBackground(pos: CGPoint(x: -380, y: 320), color: SKColor(red: 0.22, green: 0.48, blue: 0.22, alpha: 1.0), title: "RURAL HILLS")
        addZoneBackground(pos: CGPoint(x: 380, y: 320), color: SKColor(red: 0.23, green: 0.26, blue: 0.32, alpha: 1.0), title: "URBAN METROPOLIS")
        addZoneBackground(pos: CGPoint(x: 380, y: -320), color: SKColor(red: 0.08, green: 0.32, blue: 0.38, alpha: 1.0), title: "MANGROVE ESTUARY")
        addZoneBackground(pos: CGPoint(x: -380, y: -320), color: SKColor(red: 0.18, green: 0.40, blue: 0.30, alpha: 1.0), title: "ECO-DISTRICT")

        let hRoad = SKShapeNode(rectOf: CGSize(width: 1400, height: 54))
        hRoad.fillColor = SKColor(white: 0.20, alpha: 0.9)
        hRoad.strokeColor = .clear
        addChild(hRoad)

        let vRoad = SKShapeNode(rectOf: CGSize(width: 54, height: 1200))
        vRoad.fillColor = SKColor(white: 0.20, alpha: 0.9)
        vRoad.strokeColor = .clear
        addChild(vRoad)
    }

    private func addZoneBackground(pos: CGPoint, color: SKColor, title: String) {
        let zone = SKShapeNode(rectOf: CGSize(width: 680, height: 580), cornerRadius: 20)
        zone.position = pos
        zone.fillColor = color
        zone.strokeColor = .clear
        addChild(zone)

        let label = SKLabelNode(text: title)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 18
        label.fontColor = .white.withAlphaComponent(0.75)
        label.position = CGPoint(x: pos.x, y: pos.y + 240)
        addChild(label)
    }

    // Low-Poly Voxel Cat Node with solid black eyes
    private func createVoxelCatNode(color: SKColor, isMayor: Bool = false) -> SKNode {
        let cat = SKNode()

        let body = SKShapeNode(rectOf: CGSize(width: 26, height: 22), cornerRadius: 3)
        body.fillColor = color
        body.strokeColor = .clear
        body.position = CGPoint(x: 0, y: -12)
        cat.addChild(body)

        let head = SKShapeNode(rectOf: CGSize(width: 36, height: 30), cornerRadius: 4)
        head.fillColor = color
        head.strokeColor = .clear
        cat.addChild(head)

        let leftEar = SKShapeNode(rectOf: CGSize(width: 10, height: 10), cornerRadius: 2)
        leftEar.fillColor = color
        leftEar.strokeColor = .clear
        leftEar.position = CGPoint(x: -12, y: 16)
        cat.addChild(leftEar)

        let rightEar = SKShapeNode(rectOf: CGSize(width: 10, height: 10), cornerRadius: 2)
        rightEar.fillColor = color
        rightEar.strokeColor = .clear
        rightEar.position = CGPoint(x: 12, y: 16)
        cat.addChild(rightEar)

        // Solid black eyes
        let leftEye = SKShapeNode(rectOf: CGSize(width: 4, height: 4))
        leftEye.fillColor = .black
        leftEye.position = CGPoint(x: -6, y: 2)
        cat.addChild(leftEye)

        let rightEye = SKShapeNode(rectOf: CGSize(width: 4, height: 4))
        rightEye.fillColor = .black
        rightEye.position = CGPoint(x: 6, y: 2)
        cat.addChild(rightEye)

        let mouth = SKLabelNode(text: "w")
        mouth.fontName = "Courier-Bold"
        mouth.fontSize = 14
        mouth.fontColor = .black
        mouth.position = CGPoint(x: 0, y: -7)
        cat.addChild(mouth)

        if isMayor {
            let hat = SKShapeNode(rectOf: CGSize(width: 22, height: 12), cornerRadius: 2)
            hat.fillColor = .black
            hat.strokeColor = .clear
            hat.position = CGPoint(x: 0, y: 22)
            cat.addChild(hat)
        }

        return cat
    }

    // Low-Poly Voxel Slime Node with solid black eyes
    private func createVoxelSlimeNode() -> SKNode {
        let slime = SKNode()

        let body = SKShapeNode(rectOf: CGSize(width: 34, height: 26), cornerRadius: 6)
        body.fillColor = .systemPurple
        body.strokeColor = .clear
        slime.addChild(body)

        // Solid black eyes
        let leftEye = SKShapeNode(rectOf: CGSize(width: 4, height: 4))
        leftEye.fillColor = .black
        leftEye.position = CGPoint(x: -7, y: 3)
        slime.addChild(leftEye)

        let rightEye = SKShapeNode(rectOf: CGSize(width: 4, height: 4))
        rightEye.fillColor = .black
        rightEye.position = CGPoint(x: 7, y: 3)
        slime.addChild(rightEye)

        let mouth = SKShapeNode(rectOf: CGSize(width: 12, height: 3))
        mouth.fillColor = .black
        mouth.position = CGPoint(x: 0, y: -4)
        slime.addChild(mouth)

        return slime
    }

    private func setupCatPlayer() {
        auraRing.strokeColor = .systemYellow
        auraRing.fillColor = .systemYellow.withAlphaComponent(0.15)
        auraRing.lineWidth = 2.5
        catPlayer.addChild(auraRing)

        let playerSprite = createVoxelCatNode(color: .systemOrange)
        catPlayer.addChild(playerSprite)

        catPlayer.position = .zero
        catPlayer.zPosition = 20
        addChild(catPlayer)
    }

    func spawnEntities() {
        guard let curriculum else { return }

        children
            .filter { $0.name?.hasPrefix("world-entity-") == true }
            .forEach { $0.removeFromParent() }

        for quest in curriculum.quests {
            let container = SKNode()
            container.name = "world-entity-quest-\(quest.id)"
            container.position = quest.position
            container.zPosition = 10

            let ring = SKShapeNode(circleOfRadius: 40)
            ring.strokeColor = quest.isCompleted ? .systemGreen : .systemCyan
            ring.fillColor = (quest.isCompleted ? UIColor.systemGreen : UIColor.systemCyan).withAlphaComponent(0.2)
            ring.lineWidth = 3
            container.addChild(ring)

            let npcColor: SKColor = quest.id == "hierarchy" ? .systemPurple : (quest.id == "services" ? .systemCyan : .systemTeal)
            let npcSprite = createVoxelCatNode(color: quest.isCompleted ? .systemGreen : npcColor, isMayor: quest.id == "hierarchy")
            container.addChild(npcSprite)

            let badge = SKLabelNode(text: quest.npcName)
            badge.fontName = "AvenirNext-Bold"
            badge.fontSize = 12
            badge.fontColor = .white
            badge.position = CGPoint(x: 0, y: -52)
            container.addChild(badge)

            let floatUp = SKAction.moveBy(x: 0, y: 8, duration: 1.0)
            floatUp.timingMode = .easeInEaseOut
            container.run(SKAction.repeatForever(SKAction.sequence([floatUp, floatUp.reversed()])))

            addChild(container)
        }

        for enemy in curriculum.enemies {
            let container = SKNode()
            container.name = "world-entity-enemy-\(enemy.id)"
            container.position = enemy.position
            container.zPosition = 10

            if !enemy.isPurified {
                let hazardRing = SKShapeNode(circleOfRadius: 40)
                hazardRing.strokeColor = .systemPurple
                hazardRing.fillColor = UIColor.systemPurple.withAlphaComponent(0.25)
                hazardRing.lineWidth = 3
                container.addChild(hazardRing)

                let slimeSprite = createVoxelSlimeNode()
                container.addChild(slimeSprite)

                let label = SKLabelNode(text: enemy.name)
                label.fontName = "AvenirNext-Bold"
                label.fontSize = 12
                label.fontColor = .systemPink
                label.position = CGPoint(x: 0, y: -52)
                container.addChild(label)

                let patrol = SKAction.sequence([
                    SKAction.moveBy(x: 60, y: 35, duration: 2.2),
                    SKAction.moveBy(x: -60, y: -35, duration: 2.2),
                    SKAction.moveBy(x: -50, y: 40, duration: 2.0),
                    SKAction.moveBy(x: 50, y: -40, duration: 2.0)
                ])
                container.run(SKAction.repeatForever(patrol))
            } else {
                let ecoRing = SKShapeNode(circleOfRadius: 42)
                ecoRing.strokeColor = .systemGreen
                ecoRing.fillColor = UIColor.systemGreen.withAlphaComponent(0.3)
                ecoRing.lineWidth = 3
                container.addChild(ecoRing)

                let blockTrunk = SKShapeNode(rectOf: CGSize(width: 12, height: 22))
                blockTrunk.fillColor = .brown
                blockTrunk.position = CGPoint(x: 0, y: -6)
                container.addChild(blockTrunk)

                let blockLeaves = SKShapeNode(rectOf: CGSize(width: 30, height: 26), cornerRadius: 4)
                blockLeaves.fillColor = .systemGreen
                blockLeaves.position = CGPoint(x: 0, y: 14)
                container.addChild(blockLeaves)

                let healedLabel = SKLabelNode(text: "Restored!")
                healedLabel.fontName = "AvenirNext-Bold"
                healedLabel.fontSize = 12
                healedLabel.fontColor = .systemGreen
                healedLabel.position = CGPoint(x: 0, y: -52)
                container.addChild(healedLabel)
            }

            addChild(container)
        }
    }

    func triggerMeowPulse() {
        SoundManager.shared.play(.meow)
        let wave = SKShapeNode(circleOfRadius: 20)
        wave.position = catPlayer.position
        wave.strokeColor = .systemYellow
        wave.lineWidth = 4
        wave.zPosition = 15
        addChild(wave)

        let expand = SKAction.scale(to: 6.0, duration: 0.45)
        let fade = SKAction.fadeOut(withDuration: 0.45)
        wave.run(SKAction.sequence([SKAction.group([expand, fade]), SKAction.removeFromParent()]))
    }

    override func update(_ currentTime: TimeInterval) {
        let dt: CGFloat = 1.0 / 60.0

        if movementVector.dx != 0 || movementVector.dy != 0 {
            let nextX = max(-700, min(700, catPlayer.position.x + movementVector.dx * moveSpeed * dt))
            let nextY = max(-600, min(600, catPlayer.position.y + movementVector.dy * moveSpeed * dt))
            catPlayer.position = CGPoint(x: nextX, y: nextY)

            if currentTime - lastStepTime > 0.28 {
                SoundManager.shared.play(.step)
                lastStepTime = currentTime
            }
        }

        cam.position = CGPoint(
            x: cam.position.x + (catPlayer.position.x - cam.position.x) * 0.12,
            y: cam.position.y + (catPlayer.position.y - cam.position.y) * 0.12
        )

        updateCurrentBiomeLabel()

        guard currentTime > cooldownTimer else { return }
        guard let curriculum else { return }

        for quest in curriculum.quests {
            if hypot(catPlayer.position.x - quest.position.x, catPlayer.position.y - quest.position.y) < 55 {
                cooldownTimer = currentTime + 2.5
                movementVector = .zero
                worldDelegate?.didApproachQuest(quest)
                return
            }
        }

        for enemy in curriculum.enemies where !enemy.isPurified {
            let nodeName = "world-entity-enemy-\(enemy.id)"
            guard let enemyNode = childNode(withName: nodeName) else { continue }

            if hypot(catPlayer.position.x - enemyNode.position.x, catPlayer.position.y - enemyNode.position.y) < 55 {
                cooldownTimer = currentTime + 2.5
                movementVector = .zero
                worldDelegate?.didApproachEnemy(enemy)
                return
            }
        }
    }

    private func updateCurrentBiomeLabel() {
        let p = catPlayer.position
        let zone: String
        if p.x < 0 && p.y >= 0 { zone = "Whispering Hills" }
        else if p.x >= 0 && p.y >= 0 { zone = "Meowtropolis CBD" }
        else if p.x >= 0 && p.y < 0 { zone = "Tidal Mangroves" }
        else { zone = "Solar Eco-District" }
        worldDelegate?.didUpdateZone(zone)
    }
}
