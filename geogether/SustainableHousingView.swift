import SwiftUI

struct SustainableHousingView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.98, blue: 0.95)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    HousingMapScene()

                    IntegratedLandUseStudyCard()
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .frame(maxWidth: 850, alignment: .top)
                .frame(maxWidth: .infinity, alignment: .top)
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
        .navigationTitle("Sustainable Housing")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct IntegratedLandUseStudyCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "graduationcap.fill")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color(red: 0.20, green: 0.43, blue: 0.34))
                    .frame(width: 48, height: 48)
                    .background(Color(red: 0.87, green: 0.93, blue: 0.83), in: RoundedRectangle(cornerRadius: 15))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Remember with DEAD")
                        .font(.title3.bold())
                        .foregroundStyle(Color(red: 0.16, green: 0.28, blue: 0.24))
                    Text("Integrated land-use planning")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Text("Plan homes, services and jobs together to build a liveable town.")
                .font(.headline)
                .foregroundStyle(Color(red: 0.20, green: 0.36, blue: 0.30))
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 14) {
                StudyPoint(
                    letter: "D",
                    title: "Definition",
                    color: Color(red: 0.23, green: 0.52, blue: 0.41),
                    text: "Planning how different groups’ needs and competing demands can be balanced to support sustainable city development."
                )
                StudyPoint(
                    letter: "E",
                    title: "Explanation",
                    color: Color(red: 0.20, green: 0.48, blue: 0.64),
                    text: "Housing should be planned alongside other city functions, such as jobs, industry and entertainment. Amenities, transport and support services should be built within or near housing areas."
                )
                StudyPoint(
                    letter: "A",
                    title: "Advantage",
                    color: Color(red: 0.67, green: 0.48, blue: 0.19),
                    text: "Singapore’s HDB plans self-contained towns with homes, shops, industry, education, healthcare and recreation. Building these services together helps create sustainable, liveable towns."
                )
                StudyPoint(
                    letter: "D",
                    title: "Disadvantage",
                    color: Color(red: 0.68, green: 0.35, blue: 0.32),
                    text: "Planning takes coordination among many stakeholders. This can be difficult when groups have competing views."
                )
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(Color(red: 0.78, green: 0.85, blue: 0.73), lineWidth: 1)
        }
        .shadow(color: Color(red: 0.27, green: 0.40, blue: 0.30).opacity(0.08), radius: 14, y: 7)
        .accessibilityElement(children: .contain)
    }
}

private struct StudyPoint: View {
    let letter: String
    let title: String
    let color: Color
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(letter)
                .font(.headline.weight(.heavy))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(color, in: RoundedRectangle(cornerRadius: 10))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(color)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(Color(red: 0.23, green: 0.28, blue: 0.25))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SustainableHousingView()
    }
}
