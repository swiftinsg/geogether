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
        NavigationLink {
            StudyPointDetailView(letter: letter, title: title, color: color, text: text)
        } label: {
            HStack(alignment: .center, spacing: 12) {
                Text(letter)
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(color, in: RoundedRectangle(cornerRadius: 10))
                    .accessibilityHidden(true)

                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(color)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(color.opacity(0.65))
                    .padding(.top, 8)
                    .accessibilityHidden(true)
            }
            .padding(14)
            .background {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.white)
                    .shadow(color: color.opacity(0.20), radius: 10, y: 4)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(color.opacity(0.32), lineWidth: 1)
                    .shadow(color: color.opacity(0.38), radius: 7)
            }
            .contentShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(StudyPointButtonStyle(color: color))
        .accessibilityHint("Opens more about \\(title.lowercased())")
    }
}

private struct StudyPointButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .brightness(configuration.isPressed ? 0.03 : 0)
            .shadow(color: color.opacity(configuration.isPressed ? 0.42 : 0.16), radius: configuration.isPressed ? 14 : 7, y: 3)
            .animation(.easeOut(duration: 0.18), value: configuration.isPressed)
    }
}

private struct StudyPointDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let letter: String
    let title: String
    let color: Color
    let text: String

    private var memoryCue: String {
        switch title {
        case "Definition": "Definition = the city’s balancing act: fit people’s different needs together."
        case "Explanation": "Explanation = connect the dots: homes + jobs + services + transport."
        case "Advantage": "Advantage = a town with the essentials close by: live, work, learn and play."
        default: "Disadvantage = coordination is hard when many groups want different things."
        }
    }

    private var recallPrompt: String {
        switch title {
        case "Definition": "What needs to be balanced when planning a sustainable city?"
        case "Explanation": "Name two services that should be near homes."
        case "Advantage": "How does planning services together make a town more liveable?"
        default: "Why can planning across many stakeholders be difficult?"
        }
    }

    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.98, blue: 0.95).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                Text(letter)
                    .font(.largeTitle.weight(.heavy))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(color, in: RoundedRectangle(cornerRadius: 18))

                Text(title)
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color(red: 0.16, green: 0.28, blue: 0.24))

                Text(text)
                    .font(.title3)
                    .foregroundStyle(Color(red: 0.23, green: 0.28, blue: 0.25))
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: 10) {
                    Label("Memory cue", systemImage: "sparkles")
                        .font(.headline)
                        .foregroundStyle(color)

                    Text(memoryCue)
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color(red: 0.20, green: 0.30, blue: 0.26))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(color.opacity(0.10), in: RoundedRectangle(cornerRadius: 18))
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(color.opacity(0.24), lineWidth: 1)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Quick recall")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(color)
                    Text(recallPrompt)
                        .font(.subheadline)
                        .foregroundStyle(Color(red: 0.30, green: 0.35, blue: 0.31))
                }

                Spacer(minLength: 0)
            }
            .padding(24)
            .frame(maxWidth: 600, maxHeight: .infinity, alignment: .topLeading)
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
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SustainableHousingView()
    }
}
