import SwiftUI

struct RuralScene: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.55, green: 0.80, blue: 0.98), Color(red: 0.90, green: 0.97, blue: 1)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                Circle()
                    .fill(.yellow)
                    .frame(width: 54, height: 54)
                    .position(x: geometry.size.width * 0.78, y: geometry.size.height * 0.16)

                Ellipse()
                    .fill(Color(red: 0.45, green: 0.75, blue: 0.40))
                    .frame(width: geometry.size.width * 1.2, height: geometry.size.height * 0.55)
                    .position(x: geometry.size.width * 0.25, y: geometry.size.height * 0.95)
                Ellipse()
                    .fill(Color(red: 0.30, green: 0.65, blue: 0.32))
                    .frame(width: geometry.size.width * 1.2, height: geometry.size.height * 0.5)
                    .position(x: geometry.size.width * 0.80, y: geometry.size.height)

                Image(systemName: "house.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color(red: 0.75, green: 0.35, blue: 0.25))
                    .position(x: geometry.size.width * 0.30, y: geometry.size.height * 0.66)
                Image(systemName: "house.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color(red: 0.55, green: 0.40, blue: 0.30))
                    .position(x: geometry.size.width * 0.58, y: geometry.size.height * 0.74)
                Image(systemName: "tree.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(Color(red: 0.10, green: 0.50, blue: 0.20))
                    .position(x: geometry.size.width * 0.14, y: geometry.size.height * 0.70)
                Image(systemName: "tree.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Color(red: 0.10, green: 0.50, blue: 0.20))
                    .position(x: geometry.size.width * 0.82, y: geometry.size.height * 0.78)

                CatCharacter(accessory: "leaf.fill", tint: .green)
                    .frame(width: 72, height: 76)
                    .position(x: geometry.size.width * 0.70, y: geometry.size.height - 42)
            }
        }
    }
}
