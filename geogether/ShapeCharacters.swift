import SwiftUI

// MARK: - Low-Poly / Voxel Blocky Cat Avatar
struct ShapeCatView: View {
    var bodyColor: Color = .orange
    var size: CGFloat = 80
    var isMayor: Bool = false
    
    @State private var bounce = false
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(bodyColor.opacity(0.85))
                .frame(width: size * 0.16, height: size * 0.45)
                .offset(x: size * 0.42, y: size * 0.1)
                .rotationEffect(.degrees(25), anchor: .bottom)
            
            RoundedRectangle(cornerRadius: 4)
                .fill(bodyColor)
                .frame(width: size * 0.7, height: size * 0.55)
                .offset(y: size * 0.38)
            
            ZStack {
                HStack(spacing: size * 0.44) {
                    Rectangle().fill(bodyColor).frame(width: size * 0.24, height: size * 0.24).rotationEffect(.degrees(-15))
                    Rectangle().fill(bodyColor).frame(width: size * 0.24, height: size * 0.24).rotationEffect(.degrees(15))
                }
                .offset(y: -size * 0.36)
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(bodyColor)
                    .frame(width: size * 1.0, height: size * 0.82)
                
                VStack(spacing: size * 0.1) {
                    HStack(spacing: size * 0.34) {
                        Rectangle().fill(Color.black).frame(width: size * 0.14, height: size * 0.14)
                        Rectangle().fill(Color.black).frame(width: size * 0.14, height: size * 0.14)
                    }
                    
                    Text("w")
                        .font(.system(size: size * 0.35, weight: .black, design: .monospaced))
                        .foregroundColor(.black)
                }
                
                if isMayor {
                    VStack(spacing: 0) {
                        Rectangle().fill(Color.black).frame(width: size * 0.35, height: size * 0.28)
                        Rectangle().fill(Color.black).frame(width: size * 0.58, height: size * 0.06)
                    }
                    .offset(y: -size * 0.56)
                }
            }
            .offset(y: bounce ? -6 : 6)
        }
        .frame(width: size * 1.3, height: size * 1.3)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.55).repeatForever(autoreverses: true)) {
                bounce.toggle()
            }
        }
    }
}

// MARK: - Squishy Low-Poly Slime Animation
struct ShapeMonsterView: View {
    var size: CGFloat = 85
    var isDefeated: Bool = false
    
    @State private var squishStretch = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(isDefeated ? Color.gray : Color.purple)
                .frame(
                    width: isDefeated ? size * 0.9 : (squishStretch ? size * 1.35 : size * 0.85),
                    height: isDefeated ? size * 0.7 : (squishStretch ? size * 0.65 : size * 1.15)
                )
                .rotationEffect(.degrees(isDefeated ? 45 : 0))
            
            if isDefeated {
                Text("X X")
                    .font(.system(size: size * 0.35, weight: .black))
                    .foregroundColor(.white)
            } else {
                VStack(spacing: 6) {
                    HStack(spacing: 18) {
                        Rectangle().fill(Color.yellow).frame(width: 14, height: 14)
                        Rectangle().fill(Color.yellow).frame(width: 14, height: 14)
                    }
                    Rectangle().fill(Color.black).frame(width: 28, height: 5)
                }
                .scaleEffect(squishStretch ? 1.05 : 0.95)
            }
        }
        .animation(.interpolatingSpring(stiffness: 280, damping: 6).repeatForever(autoreverses: true), value: squishStretch)
        .onAppear {
            squishStretch = true
        }
    }
}

// MARK: - Geography Stage Backdrop
struct GeographyStageBackdrop: View {
    let questId: String
    let isSolved: Bool
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSolved ? Color.green.opacity(0.35) : Color.white.opacity(0.08))
                    .frame(height: 55)
            }
            
            switch questId {
            case "hierarchy":
                HStack(alignment: .bottom, spacing: 6) {
                    Rectangle().fill(Color.brown).frame(width: 20, height: 24)
                    Rectangle().fill(Color.orange).frame(width: 26, height: 36)
                    Rectangle().fill(Color.blue).frame(width: 32, height: showHeight(60))
                    Rectangle().fill(Color.cyan).frame(width: 38, height: showHeight(100))
                    Rectangle().fill(Color.indigo).frame(width: 34, height: showHeight(85))
                }
                .padding(.bottom, 25)
            case "mangroves":
                VStack {
                    Spacer()
                    ZStack(alignment: .bottom) {
                        HStack(spacing: 14) {
                            ForEach(0..<9, id: \.self) { i in
                                Rectangle().fill(Color.brown).frame(width: 6, height: isSolved ? CGFloat(28 + (i % 3) * 10) : 10)
                            }
                        }
                        .padding(.bottom, 22)
                        Rectangle().fill(Color.blue.opacity(0.45)).frame(height: 32)
                    }
                }
            case "housing":
                HStack(alignment: .bottom, spacing: 16) {
                    VStack(spacing: 0) {
                        if isSolved { Rectangle().fill(Color.blue).frame(width: 52, height: 8) }
                        Rectangle().fill(Color.mint).frame(width: 48, height: 60)
                    }
                    if isSolved {
                        VStack(spacing: 0) {
                            Rectangle().fill(Color.green).frame(width: 32, height: 32)
                            Rectangle().fill(Color.brown).frame(width: 6, height: 20)
                        }
                    }
                }
                .padding(.bottom, 25)
            default:
                HStack(alignment: .bottom, spacing: 35) {
                    Rectangle().fill(Color.red).frame(width: 32, height: 32)
                    Rectangle().fill(Color.cyan).frame(width: 36, height: showHeight(90))
                }
                .padding(.bottom, 25)
            }
        }
        .frame(height: 170)
        .padding(.horizontal)
    }
    
    private func showHeight(_ h: CGFloat) -> CGFloat {
        return isSolved ? h : 40
    }
}
