import SwiftUI

struct HousingLocationDetailView: View {
    let location: HousingLocation

    var body: some View {
        Group {
            if location == .community {
                CommunityCentreView()
            } else {
                Color(red: 0.96, green: 0.97, blue: 0.94)
                    .ignoresSafeArea()
            }
        }
        .navigationTitle(Text(location.title))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        HousingLocationDetailView(location: .community)
    }
}
