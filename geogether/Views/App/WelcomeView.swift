import SwiftUI

/// Opening screen adapted from the `kudasyroba` prototype.
struct WelcomeView: View {
    @State private var showTitle = false
    @State private var showButton = false
    @State private var waterStart = Date()
    @State private var showTopics = false

    var body: some View {
        ZStack {
            if showTopics {
                TopicListView {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        showTopics = false
                    }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                welcome
                    .transition(.opacity)
            }
        }
    }

    private var welcome: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.85, green: 0.95, blue: 1), .white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            RisingWaterView(start: waterStart)
                .ignoresSafeArea()
                .accessibilityHidden(true)

            VStack(spacing: 0) {
                Spacer().frame(height: 100)

                VStack(spacing: 4) {
                    Text("Welcome to Geogether")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(AppPalette.navy)
                        .multilineTextAlignment(.center)

                    Text("Geography, together")
                        .font(.system(size: 17))
                        .italic()
                        .foregroundStyle(AppPalette.navy.opacity(0.7))
                }
                .padding(.horizontal, 24)
                .scaleEffect(showTitle ? 1 : 0.3)
                .opacity(showTitle ? 1 : 0)
                .offset(y: showTitle ? 0 : 40)
                .contentShape(Rectangle())
                .onTapGesture(perform: replayAnimation)

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        showTopics = true
                    }
                } label: {
                    Text("Start learning")
                        .font(.headline)
                        .foregroundStyle(AppPalette.blue)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 15)
                        .background(Capsule().fill(.white))
                        .shadow(color: .black.opacity(0.22), radius: 8, y: 4)
                }
                .buttonStyle(.plain)
                .opacity(showButton ? 1 : 0)
                .scaleEffect(showButton ? 1 : 0.6)
                .offset(y: showButton ? 0 : 30)
                .padding(.bottom, 50)
            }
            .onAppear(perform: startAnimation)
        }
    }

    private func startAnimation() {
        withAnimation(.spring(response: 0.55, dampingFraction: 0.55).delay(1.15)) {
            showTitle = true
        }
        withAnimation(.spring(response: 0.55, dampingFraction: 0.6).delay(2.4)) {
            showButton = true
        }
    }

    private func replayAnimation() {
        showTitle = false
        showButton = false
        waterStart = Date()
        startAnimation()
    }
}

#Preview {
    WelcomeView()
        .environmentObject(ProgressStore())
}
