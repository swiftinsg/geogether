import SwiftUI

struct SustainableHousingView: View {
    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.98, blue: 0.95)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    HousingMapScene()

                    // Add future sections here, below the map.
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .frame(maxWidth: 850, alignment: .top)
                .frame(maxWidth: .infinity, alignment: .top)
            }
        }
        .navigationTitle("Sustainable Housing")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SustainableHousingView()
    }
}
