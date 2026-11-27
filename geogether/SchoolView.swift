import SwiftUI

struct SchoolView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedPage = 0

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedPage) {
                ForEach(SchoolPage.pages) { page in
                    SchoolPageView(page: page)
                        .tag(page.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            SchoolPageControls(selectedPage: selectedPage, changePage: changePage)
        }
        .background {
            LinearGradient(
                colors: SchoolPage.pages[selectedPage].colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(0.4)
            .ignoresSafeArea()
        }
    }

    private func changePage(by offset: Int) {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) {
            selectedPage = min(max(selectedPage + offset, 0), SchoolPage.pages.count - 1)
        }
    }
}

private struct SchoolPageControls: View {
    let selectedPage: Int
    let changePage: (Int) -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button("Previous", systemImage: "globe.badge.chevron.backward") {
                changePage(-1)
            }
            .disabled(selectedPage == 0)

            Spacer(minLength: 0)

            Text("\(selectedPage + 1) of \(SchoolPage.pages.count)")
                .font(.subheadline.monospacedDigit())
                .accessibilityLabel("Page \(selectedPage + 1) of \(SchoolPage.pages.count)")

            Spacer(minLength: 0)

            Button("Next", systemImage: "chevron.right") {
                changePage(1)
            }
            .disabled(selectedPage == SchoolPage.pages.count - 1)
        }
        .font(.subheadline.weight(.semibold))
        .padding()
        .background(.background.opacity(0.9))
    }
}

private struct SchoolPageView: View {
    let page: SchoolPage
    @State private var showsImage = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Button {
                    showsImage = true
                } label: {
                    SchoolArtwork()
                        .overlay(alignment: .bottomTrailing) {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .font(.headline)
                                .padding(10)
                                .background(.regularMaterial, in: Circle())
                                .padding(12)
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Enlarge school image")
                .accessibilityHint("Opens an image you can pinch to zoom")
                .frame(maxWidth: 440)
                .frame(maxWidth: .infinity)

                SchoolPageHeader(title: page.title, subtitle: page.subtitle, symbol: page.symbol)

                VStack(alignment: .leading, spacing: 24) {
                    ForEach(page.points) { point in
                        SchoolPointView(point: point)
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.background.opacity(0.85), in: RoundedRectangle(cornerRadius: 24))

                Text("Swipe to explore")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
            .padding(24)
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
        }
        .fullScreenCover(isPresented: $showsImage) {
            HousingImageViewer(location: .school)
        }
    }
}

struct SchoolArtwork: View {
    var body: some View {
        Image("School")
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .accessibilityHidden(true)
    }
}

private struct SchoolPageHeader: View {
    let title: LocalizedStringResource
    let subtitle: LocalizedStringResource
    let symbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("SCHOOL", systemImage: symbol)
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)

            Text(title)
                .font(.largeTitle.bold())
                .accessibilityAddTraits(.isHeader)

            Text(subtitle)
                .font(.title3.weight(.medium))
                .foregroundStyle(.secondary)
        }
    }
}

private struct SchoolPointView: View {
    let point: SchoolPoint

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(point.title)
                .font(.headline)
            Text(point.description)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct SchoolPoint: Identifiable {
    let id: Int
    let title: LocalizedStringResource
    let description: LocalizedStringResource
}

private struct SchoolPage: Identifiable {
    let id: Int
    let title: LocalizedStringResource
    let subtitle: LocalizedStringResource
    let symbol: String
    let colors: [Color]
    let points: [SchoolPoint]

    static let pages: [SchoolPage] = [
        SchoolPage(
            id: 0,
            title: "A — Accessibility",
            subtitle: "Essentials close to home",
            symbol: "figure.walk",
            colors: [.cyan, .blue, .mint],
            points: [
                SchoolPoint(id: 0, title: "• Meet basic needs", description: "Schools, clinics and markets near homes give residents easy access to essential services."),
                SchoolPoint(id: 1, title: "• Save time and money", description: "Walking or a short bus ride to school reduces travel time and transport costs for families."),
                SchoolPoint(id: 2, title: "• Reduce emissions", description: "Walking, cycling and buses mean fewer car trips, less congestion and lower carbon emissions.")
            ]
        ),
        SchoolPage(
            id: 1,
            title: "B — Balanced Land Use",
            subtitle: "Live, work, learn and play",
            symbol: "building.2.fill",
            colors: [.orange, .pink, .yellow],
            points: [
                SchoolPoint(id: 0, title: "• Self-contained towns", description: "HDB towns plan homes, jobs and services together so daily needs can be met nearby."),
                SchoolPoint(id: 1, title: "• High density, high demand", description: "High-rise housing brings many families and school-going children into a small area."),
                SchoolPoint(id: 2, title: "• Schools where needed", description: "Multiple primary and secondary schools serve the large local population.")
            ]
        ),
        SchoolPage(
            id: 2,
            title: "C — Community",
            subtitle: "Shared schools, stronger bonds",
            symbol: "person.3.fill",
            colors: [.mint, .green, .cyan],
            points: [
                SchoolPoint(id: 0, title: "• Daily interaction", description: "Neighbourhood schools bring children and parents from the same estate together each day."),
                SchoolPoint(id: 1, title: "• Sense of place", description: "Friendships and shared experiences build belonging and attachment to the neighbourhood.")
            ]
        ),
        SchoolPage(
            id: 3,
            title: "D — Daily Well-being",
            subtitle: "Better lives and opportunities",
            symbol: "heart.fill",
            colors: [.indigo, .purple, .pink],
            points: [
                SchoolPoint(id: 0, title: "• Better quality of life", description: "Nearby education and services support well-being and help families raise children."),
                SchoolPoint(id: 1, title: "• Future opportunities", description: "Access to education improves future opportunities and social mobility."),
                SchoolPoint(id: 2, title: "• Supportive housing", description: "Planned housing provides essential services that informal settlements often lack.")
            ]
        ),
        SchoolPage(
            id: 4,
            title: "G3 Exam Tip: PEEL",
            subtitle: "Why are schools near public housing?",
            symbol: "pencil.and.list.clipboard",
            colors: [.yellow, .orange, .mint],
            points: [
                SchoolPoint(id: 0, title: "• Point", description: "Nearby schools improve access to education."),
                SchoolPoint(id: 1, title: "• Explain", description: "High-density housing creates high demand for schools."),
                SchoolPoint(id: 2, title: "• Example", description: "Children in HDB estates can walk or take short bus rides to school."),
                SchoolPoint(id: 3, title: "• Link", description: "Families save time and money; fewer car trips cut emissions; shared schools strengthen community ties."),
                SchoolPoint(id: 4, title: "Remember ABCD", description: "Accessibility • Balanced land use • Community • Daily well-being. Always link back to people and sustainability.")
            ]
        )
    ]
}

#Preview {
    NavigationStack {
        HousingLocationDetailView(location: .school)
    }
}
