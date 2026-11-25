import SwiftUI

struct HousingLocationDetailView: View {
    @Environment(\.dismiss) private var dismiss

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
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "globe.badge.chevron.backward")
                        .font(.body)
                }
                .accessibilityLabel("Back")
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
