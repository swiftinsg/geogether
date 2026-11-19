import SwiftUI

// MARK: - Character & Helpers

struct CatCharacter: View {
    let accessory: String
    let tint: Color

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            ZStack {
                Triangle()
                    .fill(Color(red: 0.95, green: 0.76, blue: 0.48))
                    .frame(width: size * 0.30, height: size * 0.30)
                    .rotationEffect(.degrees(-18))
                    .offset(x: -size * 0.24, y: -size * 0.29)
                Triangle()
                    .fill(Color(red: 0.95, green: 0.76, blue: 0.48))
                    .frame(width: size * 0.30, height: size * 0.30)
                    .rotationEffect(.degrees(18))
                    .offset(x: size * 0.24, y: -size * 0.29)

                Circle()
                    .fill(Color(red: 0.95, green: 0.76, blue: 0.48))
                    .overlay {
                        VStack(spacing: size * 0.06) {
                            HStack(spacing: size * 0.19) {
                                Circle().frame(width: size * 0.06, height: size * 0.06)
                                Circle().frame(width: size * 0.06, height: size * 0.06)
                            }
                            Text("ω")
                                .font(.system(size: size * 0.19, weight: .medium, design: .rounded))
                        }
                        .foregroundStyle(AppPalette.navy)
                    }
                    .padding(size * 0.08)

                Image(systemName: accessory)
                    .font(.system(size: size * 0.20, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(size * 0.09)
                    .background(Circle().fill(tint))
                    .offset(x: size * 0.34, y: size * 0.31)
            }
        }
        .accessibilityHidden(true)
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}
