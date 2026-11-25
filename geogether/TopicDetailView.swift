import SwiftUI

struct TopicDetailView: View {
    let title: LocalizedStringKey
    let symbol: String

    var body: some View {
        ZStack {
            MovingBlueBackground()

            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: symbol)
                        .font(.system(size: 72, weight: .semibold))
                        .foregroundStyle(.white)
                        .accessibilityHidden(true)

                    Text(title)
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .accessibilityAddTraits(.isHeader)
                }
                .padding(32)
                .frame(maxWidth: .infinity)
                .shadow(color: .black.opacity(0.25), radius: 8, y: 3)
                .padding(24)
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        TopicDetailView(title: "Sustainable Housing", symbol: "house.fill")
    }
}
