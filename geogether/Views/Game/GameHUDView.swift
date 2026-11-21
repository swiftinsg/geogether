import SwiftUI

struct GameHUDView: View {
    let zoneName: String
    let playerLevel: Int
    let completedCount: Int
    let totalCount: Int
    let playerPosition: CGPoint
    let quests: [GeoQuest]
    let enemies: [PollutionEnemy]
    let openGuide: () -> Void
    let openInstructions: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("GeoPaws")
                        .font(.headline.bold())
                        .foregroundStyle(.white)

                    Text(zoneName)
                        .font(.caption.bold())
                        .foregroundStyle(.black)
                        .lineLimit(2)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))

                HStack(spacing: 7) {
                    GameStatusChip(symbol: "star.fill", text: "Level \(playerLevel)", tint: .blue)
                    GameStatusChip(symbol: "globe.asia.australia.fill", text: "\(completedCount)/\(totalCount)", tint: .green)

                    Button(action: openGuide) {
                        Image(systemName: "book.fill")
                            .font(.subheadline.bold())
                            .frame(width: 32, height: 32)
                            .background(.blue, in: Circle())
                            .foregroundStyle(.white)
                    }
                    .accessibilityLabel("Open field guide")

                    Button(action: openInstructions) {
                        Image(systemName: "questionmark")
                            .font(.subheadline.bold())
                            .frame(width: 32, height: 32)
                            .background(.ultraThinMaterial, in: Circle())
                            .foregroundStyle(.white)
                    }
                    .accessibilityLabel("Show game instructions")
                }
            }

            Spacer(minLength: 0)

            MiniMapView(
                playerPosition: playerPosition,
                quests: quests,
                enemies: enemies
            )
        }
    }
}

private struct GameStatusChip: View {
    let symbol: String
    let text: String
    let tint: Color

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: symbol)
                .foregroundStyle(tint)
            Text(text)
                .font(.caption.bold())
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 7)
        .background(.ultraThinMaterial, in: Capsule())
    }
}

struct MiniMapView: View {
    let playerPosition: CGPoint
    let quests: [GeoQuest]
    let enemies: [PollutionEnemy]

    private let mapSize = CGSize(width: 118, height: 98)
    private let worldSize = CGSize(width: 1500, height: 1300)

    var body: some View {
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

            Rectangle()
                .fill(.white.opacity(0.28))
                .frame(height: 2)
            Rectangle()
                .fill(.white.opacity(0.28))
                .frame(width: 2)

            ForEach(quests) { quest in
                Circle()
                    .fill(quest.isCompleted ? .green : .cyan)
                    .frame(width: 6, height: 6)
                    .position(mapPoint(for: quest.position))
            }

            ForEach(enemies) { enemy in
                if !enemy.isPurified {
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(.purple)
                        .frame(width: 6, height: 6)
                        .position(mapPoint(for: enemy.position))
                }
            }

            Circle()
                .fill(.orange)
                .stroke(.white, lineWidth: 1.5)
                .frame(width: 9, height: 9)
                .position(mapPoint(for: playerPosition))
        }
        .frame(width: mapSize.width, height: mapSize.height)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.5), lineWidth: 2))
        .shadow(radius: 4)
        .accessibilityLabel("World mini-map")
    }

    private func mapPoint(for position: CGPoint) -> CGPoint {
        let normalizedX = (position.x + worldSize.width / 2) / worldSize.width
        let normalizedY = 1 - ((position.y + worldSize.height / 2) / worldSize.height)
        return CGPoint(
            x: max(5, min(mapSize.width - 5, normalizedX * mapSize.width)),
            y: max(5, min(mapSize.height - 5, normalizedY * mapSize.height))
        )
    }
}
