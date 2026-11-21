import SpriteKit
import SwiftUI

protocol OpenWorldDelegate: AnyObject {
    func didApproachQuest(_ quest: GeoQuest)
    func didApproachEnemy(_ enemy: PollutionEnemy)
    func didUpdateZone(_ zoneName: String)
    func didUpdatePlayerPosition(_ position: CGPoint)
}

final class OpenWorldScene: SKScene {
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
    private var blockedEncounterNodeName: String?

    private let encounterDistance: CGFloat = 55
    private let encounterResetDistance: CGFloat = 85

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

        addZoneBackground(pos: CGPoint(x: -380, y: 320), color: SKColor(red: 0.22, green: 0.48, blue: 0.22, alpha: 1.0), title: "RURAL HILLS", subtitle: "Settlements and migration")
        addZoneBackground(pos: CGPoint(x: 380, y: 320), color: SKColor(red: 0.23, green: 0.26, blue: 0.32, alpha: 1.0), title: "MEOWTROPOLIS CBD", subtitle: "Services and urban climate")
        addZoneBackground(pos: CGPoint(x: 380, y: -320), color: SKColor(red: 0.08, green: 0.32, blue: 0.38, alpha: 1.0), title: "TIDAL MANGROVES", subtitle: "Coastal ecosystems")
        addZoneBackground(pos: CGPoint(x: -380, y: -320), color: SKColor(red: 0.18, green: 0.40, blue: 0.30, alpha: 1.0), title: "ECO-DISTRICT", subtitle: "Housing and sustainability")

        addBiomeScenery()

        let hRoad = SKShapeNode(rectOf: CGSize(width: 1400, height: 54))
        hRoad.fillColor = SKColor(white: 0.20, alpha: 0.9)
        hRoad.strokeColor = .clear
        hRoad.zPosition = 2
        addChild(hRoad)

        let vRoad = SKShapeNode(rectOf: CGSize(width: 54, height: 1200))
        vRoad.fillColor = SKColor(white: 0.20, alpha: 0.9)
        vRoad.strokeColor = .clear
        vRoad.zPosition = 2
        addChild(vRoad)
    }

    private func addZoneBackground(pos: CGPoint, color: SKColor, title: String, subtitle: String) {
        let zone = SKShapeNode(rectOf: CGSize(width: 680, height: 580), cornerRadius: 20)
        zone.position = pos
        zone.fillColor = color
        zone.strokeColor = .clear
        zone.zPosition = -20
        addChild(zone)

        let label = SKLabelNode(text: title)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 18
        label.fontColor = .white
        label.position = CGPoint(x: pos.x, y: pos.y + 242)
        label.zPosition = 4
        addChild(label)

        let subtitleLabel = SKLabelNode(text: subtitle)
        subtitleLabel.fontName = "AvenirNext-Medium"
        subtitleLabel.fontSize = 12
        subtitleLabel.fontColor = .systemBlue
        subtitleLabel.position = CGPoint(x: pos.x, y: pos.y + 220)
        subtitleLabel.zPosition = 4
        addChild(subtitleLabel)
    }

    private func addBiomeScenery() {
        addRuralScenery()
        addCityScenery()
        addMangroveScenery()
        addEcoDistrictScenery()
    }

    private func addRuralScenery() {
        addHill(at: CGPoint(x: -585, y: 420), size: CGSize(width: 180, height: 90))
        addHill(at: CGPoint(x: -285, y: 470), size: CGSize(width: 230, height: 110))
        addHill(at: CGPoint(x: -520, y: 175), size: CGSize(width: 210, height: 85))

        addTree(at: CGPoint(x: -640, y: 250), scale: 1.0)
        addTree(at: CGPoint(x: -470, y: 510), scale: 0.82)
        addTree(at: CGPoint(x: -260, y: 190), scale: 0.9)
        addTree(at: CGPoint(x: -125, y: 420), scale: 0.75)

        addHouse(at: CGPoint(x: -555, y: 335), wallColor: .systemOrange, roofColor: .systemRed)
        addHouse(at: CGPoint(x: -365, y: 245), wallColor: .systemYellow, roofColor: .brown)
        addHouse(at: CGPoint(x: -175, y: 515), wallColor: .systemTeal, roofColor: .systemIndigo)
    }

    private func addCityScenery() {
        addCityBuilding(at: CGPoint(x: 135, y: 420), size: CGSize(width: 72, height: 150), color: .systemIndigo)
        addCityBuilding(at: CGPoint(x: 265, y: 235), size: CGSize(width: 92, height: 185), color: .darkGray)
        addCityBuilding(at: CGPoint(x: 410, y: 475), size: CGSize(width: 82, height: 175), color: .systemBlue)
        addCityBuilding(at: CGPoint(x: 555, y: 255), size: CGSize(width: 104, height: 205), color: .gray)
        addCityBuilding(at: CGPoint(x: 655, y: 490), size: CGSize(width: 68, height: 135), color: .systemPurple)

        addTree(at: CGPoint(x: 380, y: 190), scale: 0.65)
        addTree(at: CGPoint(x: 670, y: 175), scale: 0.6)
    }

    private func addMangroveScenery() {
        addWaterPool(at: CGPoint(x: 225, y: -260), size: CGSize(width: 250, height: 115))
        addWaterPool(at: CGPoint(x: 520, y: -445), size: CGSize(width: 300, height: 120))

        addMangroveTree(at: CGPoint(x: 135, y: -180), scale: 0.85)
        addMangroveTree(at: CGPoint(x: 285, y: -430), scale: 1.0)
        addMangroveTree(at: CGPoint(x: 445, y: -205), scale: 0.9)
        addMangroveTree(at: CGPoint(x: 615, y: -405), scale: 1.08)
        addMangroveTree(at: CGPoint(x: 655, y: -205), scale: 0.72)

        addReeds(at: CGPoint(x: 170, y: -500))
        addReeds(at: CGPoint(x: 390, y: -515))
        addReeds(at: CGPoint(x: 585, y: -160))
    }

    private func addEcoDistrictScenery() {
        addEcoHouse(at: CGPoint(x: -610, y: -220), wallColor: .systemMint)
        addEcoHouse(at: CGPoint(x: -395, y: -455), wallColor: .systemBlue)
        addEcoHouse(at: CGPoint(x: -175, y: -255), wallColor: .systemGreen)
        addWindTurbine(at: CGPoint(x: -570, y: -500))
        addWindTurbine(at: CGPoint(x: -150, y: -500))

        addTree(at: CGPoint(x: -500, y: -320), scale: 0.75)
        addTree(at: CGPoint(x: -270, y: -165), scale: 0.65)
        addCommunityGarden(at: CGPoint(x: -285, y: -520))
    }

    private func addHill(at position: CGPoint, size: CGSize) {
        let hill = SKShapeNode(ellipseOf: size)
        hill.position = position
        hill.fillColor = SKColor(red: 0.30, green: 0.58, blue: 0.25, alpha: 1)
        hill.strokeColor = .clear
        hill.zPosition = -8
        addChild(hill)
    }

    private func addTree(at position: CGPoint, scale: CGFloat) {
        let tree = SKNode()
        tree.position = position
        tree.setScale(scale)
        tree.zPosition = -4

        let trunk = SKShapeNode(rectOf: CGSize(width: 14, height: 34), cornerRadius: 3)
        trunk.fillColor = .brown
        trunk.strokeColor = .clear
        trunk.position.y = -12
        tree.addChild(trunk)

        let crown = SKShapeNode(circleOfRadius: 28)
        crown.fillColor = .systemGreen
        crown.strokeColor = SKColor.white.withAlphaComponent(0.2)
        crown.position.y = 18
        tree.addChild(crown)
        crown.run(gentleSway())

        addChild(tree)
    }

    private func addHouse(at position: CGPoint, wallColor: SKColor, roofColor: SKColor) {
        let house = SKNode()
        house.position = position
        house.zPosition = -3

        let walls = SKShapeNode(rectOf: CGSize(width: 70, height: 48), cornerRadius: 4)
        walls.fillColor = wallColor
        walls.strokeColor = .clear
        house.addChild(walls)

        let roofPath = CGMutablePath()
        roofPath.move(to: CGPoint(x: -43, y: 23))
        roofPath.addLine(to: CGPoint(x: 0, y: 55))
        roofPath.addLine(to: CGPoint(x: 43, y: 23))
        roofPath.closeSubpath()
        let roof = SKShapeNode(path: roofPath)
        roof.fillColor = roofColor
        roof.strokeColor = .clear
        house.addChild(roof)

        let door = SKShapeNode(rectOf: CGSize(width: 16, height: 26), cornerRadius: 2)
        door.fillColor = .brown
        door.strokeColor = .clear
        door.position = CGPoint(x: 0, y: -11)
        house.addChild(door)

        addChild(house)
    }

    private func addCityBuilding(at position: CGPoint, size: CGSize, color: SKColor) {
        let building = SKNode()
        building.position = position
        building.zPosition = -3

        let body = SKShapeNode(rectOf: size, cornerRadius: 5)
        body.fillColor = color
        body.strokeColor = SKColor.white.withAlphaComponent(0.18)
        building.addChild(body)

        let columns = max(2, Int(size.width / 28))
        let rows = max(3, Int(size.height / 34))
        for row in 0..<rows {
            for column in 0..<columns {
                let window = SKShapeNode(rectOf: CGSize(width: 10, height: 12), cornerRadius: 2)
                window.fillColor = (row + column).isMultiple(of: 3) ? .systemYellow : .systemCyan
                window.strokeColor = .clear
                window.alpha = 0.75
                window.position = CGPoint(
                    x: CGFloat(column) * 22 - CGFloat(columns - 1) * 11,
                    y: CGFloat(row) * 27 - CGFloat(rows - 1) * 13.5
                )
                building.addChild(window)
            }
        }

        addChild(building)
    }

    private func addWaterPool(at position: CGPoint, size: CGSize) {
        let water = SKShapeNode(ellipseOf: size)
        water.position = position
        water.fillColor = SKColor(red: 0.10, green: 0.58, blue: 0.68, alpha: 0.75)
        water.strokeColor = SKColor.white.withAlphaComponent(0.35)
        water.lineWidth = 3
        water.zPosition = -9
        water.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.65, duration: 1.6),
            SKAction.fadeAlpha(to: 0.9, duration: 1.6)
        ])))
        addChild(water)
    }

    private func addMangroveTree(at position: CGPoint, scale: CGFloat) {
        let tree = SKNode()
        tree.position = position
        tree.setScale(scale)
        tree.zPosition = -3

        let trunk = SKShapeNode(rectOf: CGSize(width: 15, height: 58), cornerRadius: 4)
        trunk.fillColor = SKColor(red: 0.45, green: 0.26, blue: 0.12, alpha: 1)
        trunk.strokeColor = .clear
        trunk.position.y = 10
        tree.addChild(trunk)

        let rootsPath = CGMutablePath()
        for offset in stride(from: -28, through: 28, by: 14) {
            rootsPath.move(to: CGPoint(x: 0, y: -16))
            rootsPath.addQuadCurve(
                to: CGPoint(x: offset, y: -45),
                control: CGPoint(x: CGFloat(offset) * 0.35, y: -26)
            )
        }
        let roots = SKShapeNode(path: rootsPath)
        roots.strokeColor = SKColor(red: 0.58, green: 0.34, blue: 0.15, alpha: 1)
        roots.lineWidth = 5
        roots.lineCap = .round
        tree.addChild(roots)

        let canopy = SKNode()
        canopy.position.y = 46
        for offset in [CGPoint(x: -22, y: 0), CGPoint(x: 0, y: 12), CGPoint(x: 24, y: 0)] {
            let leaves = SKShapeNode(circleOfRadius: 24)
            leaves.fillColor = .systemGreen
            leaves.strokeColor = .clear
            leaves.position = offset
            canopy.addChild(leaves)
        }
        canopy.run(gentleSway())
        tree.addChild(canopy)

        addChild(tree)
    }

    private func addReeds(at position: CGPoint) {
        let reeds = SKNode()
        reeds.position = position
        reeds.zPosition = -2

        for index in 0..<6 {
            let reed = SKShapeNode(rectOf: CGSize(width: 3, height: CGFloat(18 + index * 3)), cornerRadius: 1)
            reed.fillColor = .systemGreen
            reed.strokeColor = .clear
            reed.position.x = CGFloat(index * 7)
            reeds.addChild(reed)
        }
        reeds.run(gentleSway())
        addChild(reeds)
    }

    private func addEcoHouse(at position: CGPoint, wallColor: SKColor) {
        addHouse(at: position, wallColor: wallColor, roofColor: .darkGray)

        let panel = SKShapeNode(rectOf: CGSize(width: 48, height: 18), cornerRadius: 2)
        panel.position = CGPoint(x: position.x, y: position.y + 46)
        panel.fillColor = .systemBlue
        panel.strokeColor = .systemCyan
        panel.lineWidth = 2
        panel.zPosition = -1
        addChild(panel)
    }

    private func addWindTurbine(at position: CGPoint) {
        let turbine = SKNode()
        turbine.position = position
        turbine.zPosition = -2

        let mast = SKShapeNode(rectOf: CGSize(width: 7, height: 90), cornerRadius: 2)
        mast.fillColor = .white
        mast.strokeColor = .clear
        turbine.addChild(mast)

        let blades = SKNode()
        blades.position.y = 45
        for angle in stride(from: 0.0, to: 360.0, by: 120.0) {
            let radians = CGFloat(angle) * .pi / 180
            let blade = SKShapeNode(rectOf: CGSize(width: 9, height: 48), cornerRadius: 4)
            blade.fillColor = .white
            blade.strokeColor = .clear
            blade.position = CGPoint(x: -sin(radians) * 22, y: cos(radians) * 22)
            blade.zRotation = -radians
            blades.addChild(blade)
        }
        blades.run(SKAction.repeatForever(SKAction.rotate(byAngle: -.pi * 2, duration: 6)))
        turbine.addChild(blades)

        addChild(turbine)
    }

    private func addCommunityGarden(at position: CGPoint) {
        let garden = SKNode()
        garden.position = position
        garden.zPosition = -2

        for row in 0..<3 {
            let bed = SKShapeNode(rectOf: CGSize(width: 88, height: 14), cornerRadius: 4)
            bed.fillColor = .brown
            bed.strokeColor = .clear
            bed.position.y = CGFloat(row * 20)
            garden.addChild(bed)

            for column in 0..<5 {
                let plant = SKShapeNode(circleOfRadius: 5)
                plant.fillColor = row.isMultiple(of: 2) ? .systemGreen : .systemMint
                plant.strokeColor = .clear
                plant.position = CGPoint(x: CGFloat(column * 17 - 34), y: CGFloat(row * 20))
                garden.addChild(plant)
            }
        }

        addChild(garden)
    }

    private func gentleSway() -> SKAction {
        let sway = SKAction.rotate(byAngle: 0.035, duration: 1.2)
        sway.timingMode = .easeInEaseOut
        return SKAction.repeatForever(SKAction.sequence([sway, sway.reversed()]))
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

            let npcColor = npcColor(named: quest.npcShapeColor)
            let npcSprite = createVoxelCatNode(color: quest.isCompleted ? .systemGreen : npcColor, isMayor: quest.id == "hierarchy")
            container.addChild(npcSprite)

            let badgeText = quest.isCompleted ? "\(quest.npcName) · Mastered" : quest.npcName
            let badge = SKLabelNode(text: badgeText)
            badge.fontName = "AvenirNext-Bold"
            badge.fontSize = 12
            badge.fontColor = .white
            badge.position = CGPoint(x: 0, y: -52)
            container.addChild(badge)

            let floatUp = SKAction.moveBy(x: 0, y: 8, duration: 1.0)
            floatUp.timingMode = .easeInEaseOut
            container.run(SKAction.repeatForever(SKAction.sequence([floatUp, floatUp.reversed()])))

            if quest.isCompleted {
                addMasteryScene(to: container)
            }

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
        worldDelegate?.didUpdatePlayerPosition(catPlayer.position)

        guard let curriculum else { return }
        guard canStartAnotherEncounter() else { return }
        guard currentTime > cooldownTimer else { return }

        for quest in curriculum.quests {
            let nodeName = "world-entity-quest-\(quest.id)"
            guard let questNode = childNode(withName: nodeName) else { continue }

            if distanceFromPlayer(to: questNode) < encounterDistance {
                cooldownTimer = currentTime + 2.5
                blockedEncounterNodeName = nodeName
                movementVector = .zero
                worldDelegate?.didApproachQuest(quest)
                return
            }
        }

        for enemy in curriculum.enemies where !enemy.isPurified {
            let nodeName = "world-entity-enemy-\(enemy.id)"
            guard let enemyNode = childNode(withName: nodeName) else { continue }

            if distanceFromPlayer(to: enemyNode) < encounterDistance {
                cooldownTimer = currentTime + 2.5
                blockedEncounterNodeName = nodeName
                movementVector = .zero
                worldDelegate?.didApproachEnemy(enemy)
                return
            }
        }
    }

    private func canStartAnotherEncounter() -> Bool {
        guard let blockedEncounterNodeName else { return true }
        guard let encounterNode = childNode(withName: blockedEncounterNodeName) else {
            self.blockedEncounterNodeName = nil
            return true
        }

        guard distanceFromPlayer(to: encounterNode) >= encounterResetDistance else {
            return false
        }

        self.blockedEncounterNodeName = nil
        return true
    }

    private func distanceFromPlayer(to node: SKNode) -> CGFloat {
        hypot(catPlayer.position.x - node.position.x, catPlayer.position.y - node.position.y)
    }

    private func updateCurrentBiomeLabel() {
        let p = catPlayer.position
        let zone: String
        if p.x < 0 && p.y >= 0 { zone = "Whispering Hills · Settlements" }
        else if p.x >= 0 && p.y >= 0 { zone = "Meowtropolis CBD · Urban studies" }
        else if p.x >= 0 && p.y < 0 { zone = "Tidal Mangroves · Coasts" }
        else { zone = "Eco-District · Sustainability" }
        worldDelegate?.didUpdateZone(zone)
    }

    private func npcColor(named name: String) -> SKColor {
        switch name {
        case "orange": return .systemOrange
        case "purple": return .systemPurple
        case "cyan": return .systemCyan
        case "green", "mint": return .systemMint
        case "blue": return .systemBlue
        case "yellow": return .systemYellow
        case "indigo": return .systemIndigo
        default: return .systemPink
        }
    }

    private func addMasteryScene(to container: SKNode) {
        for index in 0..<3 {
            let helper = createVoxelCatNode(color: .systemBlue)
            helper.setScale(0.65)
            let angle = CGFloat(index) * (2 * .pi / 3)
            helper.position = CGPoint(x: cos(angle) * 50, y: sin(angle) * 50)
            container.addChild(helper)

            let wander = SKAction.moveBy(x: cos(angle) * 18, y: sin(angle) * 18, duration: 1.6)
            helper.run(SKAction.repeatForever(SKAction.sequence([wander, wander.reversed()])))
        }

        let house = SKShapeNode(rectOf: CGSize(width: 24, height: 22), cornerRadius: 3)
        house.fillColor = .systemBlue
        house.strokeColor = .clear
        house.position = CGPoint(x: 55, y: 40)
        container.addChild(house)
    }
}
