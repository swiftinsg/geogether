import SwiftUI

struct CommunityCentreView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedPage = 0

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedPage) {
                ForEach(CommunityCentrePage.pages) { page in
                    CommunityCentrePageView(page: page)
                        .tag(page.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            HStack(spacing: 16) {
                Button("Previous", systemImage: "globe.badge.chevron.backward") {
                    changePage(by: -1)
                }
                .disabled(selectedPage == 0)

                Spacer(minLength: 0)

                Text("\(selectedPage + 1) of \(CommunityCentrePage.pages.count)")
                    .font(.subheadline.monospacedDigit())
                    .accessibilityLabel("Page \(selectedPage + 1) of \(CommunityCentrePage.pages.count)")

                Spacer(minLength: 0)

                Button("Next", systemImage: "chevron.right") {
                    changePage(by: 1)
                }
                .disabled(selectedPage == CommunityCentrePage.pages.count - 1)
            }
            .font(.subheadline.weight(.semibold))
            .padding()
            .background(.background.opacity(0.9))
        }
        .background {
            LinearGradient(
                colors: CommunityCentrePage.pages[selectedPage].colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(0.4)
            .ignoresSafeArea()
        }
    }

    private func changePage(by offset: Int) {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) {
            selectedPage = min(max(selectedPage + offset, 0), CommunityCentrePage.pages.count - 1)
        }
    }
}

private struct CommunityCentrePageView: View {
    let page: CommunityCentrePage

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HousingArtworkButton(location: .community)
                    .frame(maxWidth: 440)
                    .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 12) {
                    Label("COMMUNITY CENTRE", systemImage: page.symbol)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)

                    Text(page.title)
                        .font(.largeTitle.bold())
                        .accessibilityAddTraits(.isHeader)

                    Text(page.subtitle)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 24) {
                    ForEach(page.points) { point in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(point.title)
                                .font(.headline)
                            Text(point.description)
                                .font(.body)
                                .fixedSize(horizontal: false, vertical: true)
                        }
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
    }
}

struct CommunityCentreArtwork: View {
    var body: some View {
        Image("CommunityCentre")
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .accessibilityHidden(true)
    }
}

private struct CommunityCentrePoint: Identifiable {
    let id: Int
    let title: LocalizedStringResource
    let description: LocalizedStringResource
}

private struct CommunityCentrePage: Identifiable {
    let id: Int
    let title: LocalizedStringResource
    let subtitle: LocalizedStringResource
    let symbol: String
    let colors: [Color]
    let points: [CommunityCentrePoint]

    static let pages: [CommunityCentrePage] = [
        CommunityCentrePage(
            id: 0,
            title: "Builds Social Cohesion",
            subtitle: "Brings people together",
            symbol: "person.3.fill",
            colors: [.cyan, .blue, .mint],
            points: [
                CommunityCentrePoint(id: 0, title: "Common meeting space", description: "Gives neighbours of different ages, races, and backgrounds a place to interact and make friends."),
                CommunityCentrePoint(id: 1, title: "Shared activities", description: "Offers affordable classes (like cooking, sports, or art) and festive celebrations that help strangers bond."),
                CommunityCentrePoint(id: 2, title: "Prevents loneliness", description: "Keeps vulnerable groups, such as the elderly, active and connected to the community.")
            ]
        ),
        CommunityCentrePage(
            id: 1,
            title: "Creates a Strong Sense of Place",
            subtitle: "A neighbourhood to call home",
            symbol: "mappin.and.ellipse",
            colors: [.orange, .pink, .yellow],
            points: [
                CommunityCentrePoint(id: 0, title: "Positive memories", description: "Attending local events and hanging out at the community centre helps residents feel attached to their neighbourhood."),
                CommunityCentrePoint(id: 1, title: "Neighbourhood identity", description: "Acts as a familiar landmark in the town (like Keat Hong CC or Choa Chu Kang CC) that makes residents proud of where they live.")
            ]
        ),
        CommunityCentrePage(
            id: 2,
            title: "Improves Quality of Life",
            subtitle: "Convenience & well-being",
            symbol: "heart.fill",
            colors: [.mint, .green, .cyan],
            points: [
                CommunityCentrePoint(id: 0, title: "Accessible facilities", description: "Puts useful amenities—like study rooms, gyms, basketball courts, and childcare centres—within walking distance of homes."),
                CommunityCentrePoint(id: 1, title: "Promotes healthy living", description: "Encourages residents to exercise and pick up new skills, improving both physical and mental health.")
            ]
        ),
        CommunityCentrePage(
            id: 3,
            title: "Helps During Emergencies",
            subtitle: "Community resilience",
            symbol: "hands.sparkles.fill",
            colors: [.indigo, .purple, .pink],
            points: [
                CommunityCentrePoint(id: 0, title: "Support hub", description: "During crises (such as pandemics, haze, or power outages), community centres are used to distribute masks, food, or aid to residents."),
                CommunityCentrePoint(id: 1, title: "Communication link", description: "Helps town councils and leaders share important news and listen to residents’ feedback.")
            ]
        )
    ]
}

#Preview {
    NavigationStack {
        HousingLocationDetailView(location: .community)
    }
}
