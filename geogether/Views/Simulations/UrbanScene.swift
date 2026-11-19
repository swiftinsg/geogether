import SwiftUI

struct UrbanScene: View {
    private let heights = [0.45, 0.65, 0.38, 0.72, 0.55, 0.62, 0.42]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.70, green: 0.78, blue: 0.90), Color(red: 0.90, green: 0.92, blue: 0.95)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                HStack(alignment: .bottom, spacing: 5) {
                    ForEach(Array(heights.enumerated()), id: \.offset) { _, height in
                        ZStack {
                            Rectangle().fill(Color(red: 0.35, green: 0.42, blue: 0.55))
                            VStack(spacing: 6) {
                                ForEach(0..<6, id: \.self) { _ in
                                    HStack(spacing: 5) {
                                        ForEach(0..<3, id: \.self) { _ in
                                            Rectangle()
                                                .fill(.yellow.opacity(0.85))
                                                .frame(width: 6, height: 8)
                                        }
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }
                        .frame(height: geometry.size.height * height)
                    }
                }
                .padding(.horizontal, 8)
                .frame(maxHeight: .infinity, alignment: .bottom)

                Rectangle()
                    .fill(Color(red: 0.25, green: 0.27, blue: 0.30))
                    .frame(height: 22)
                    .frame(maxHeight: .infinity, alignment: .bottom)

                CatCharacter(accessory: "briefcase.fill", tint: .purple)
                    .frame(width: 72, height: 76)
                    .position(x: geometry.size.width * 0.72, y: geometry.size.height - 42)
            }
        }
    }
}
