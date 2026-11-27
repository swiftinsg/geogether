import SwiftUI

struct HousingStudyView: View {
    let location: HousingLocation
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedPage = 0

    var body: some View {
        let pages = HousingStudyPage.pages(for: location)

        if let page = pages.first(where: { $0.id == selectedPage }) {
            VStack(spacing: 0) {
                TabView(selection: $selectedPage) {
                    ForEach(pages) { page in
                        HousingStudyPageView(location: location, page: page)
                            .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                HousingStudyControls(selectedPage: $selectedPage, pageCount: pages.count, reduceMotion: reduceMotion)
            }
            .background {
                LinearGradient(
                    colors: page.colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(0.4)
                .ignoresSafeArea()
            }
        }
    }
}

private struct HousingStudyControls: View {
    @Binding var selectedPage: Int
    let pageCount: Int
    let reduceMotion: Bool

    var body: some View {
        HStack(spacing: 16) {
            Button("Previous", systemImage: "globe.badge.chevron.backward") {
                changePage(by: -1)
            }
            .disabled(selectedPage == 0)

            Spacer(minLength: 0)

            Text("\(selectedPage + 1) of \(pageCount)")
                .font(.subheadline.monospacedDigit())
                .accessibilityLabel("Page \(selectedPage + 1) of \(pageCount)")

            Spacer(minLength: 0)

            Button("Next", systemImage: "chevron.right") {
                changePage(by: 1)
            }
            .disabled(selectedPage == pageCount - 1)
        }
        .font(.subheadline.weight(.semibold))
        .padding()
        .background(.background.opacity(0.9))
    }

    private func changePage(by offset: Int) {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) {
            selectedPage = min(max(selectedPage + offset, 0), pageCount - 1)
        }
    }
}

private struct HousingStudyPageView: View {
    let location: HousingLocation
    let page: HousingStudyPage

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HousingArtworkButton(location: location)
                    .frame(maxWidth: 440)
                    .frame(maxWidth: .infinity)

                HousingStudyHeader(locationTitle: location.title, title: page.title, subtitle: page.subtitle, symbol: page.symbol)

                if location == .playground && page.id == 2 {
                    InclusivePlaygroundPhoto()
                }

                VStack(alignment: .leading, spacing: 24) {
                    ForEach(page.points) { point in
                        HousingStudyPointView(point: point)
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

private struct InclusivePlaygroundPhoto: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image("InclusivePlayground")
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .accessibilityLabel("Children playing at Bishan–Ang Mo Kio Park’s inclusive playground, with a merry-go-round, slides and swings.")

            Text("Bishan–Ang Mo Kio Park inclusive playground")
                .font(.subheadline.weight(.semibold))

            if let url = URL(string: "https://www.nparks.gov.sg/visit/parks/bishan-ang-mo-kio-park/amenities/playgrounds") {
                Link("Photo credit: National Parks Board (NParks)", destination: url)
                    .font(.footnote)
            }
        }
    }
}

private struct HousingStudyHeader: View {
    let locationTitle: LocalizedStringResource
    let title: LocalizedStringResource
    let subtitle: LocalizedStringResource
    let symbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text(locationTitle)
            } icon: {
                Image(systemName: symbol)
            }
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

private struct HousingStudyPointView: View {
    let point: HousingStudyPoint

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

#Preview("Public Housing") {
    NavigationStack {
        HousingLocationDetailView(location: .homes)
    }
}

#Preview("Hawker Center") {
    NavigationStack {
        HousingLocationDetailView(location: .dining)
    }
}

#Preview("Playground") {
    NavigationStack {
        HousingLocationDetailView(location: .playground)
    }
}

#Preview("All Are Welcome") {
    NavigationStack {
        if let page = HousingStudyPage.pages(for: .playground).first(where: { $0.id == 2 }) {
            HousingStudyPageView(location: .playground, page: page)
                .navigationTitle("Playground")
        }
    }
}

#Preview("Park") {
    NavigationStack {
        HousingLocationDetailView(location: .garden)
    }
}
