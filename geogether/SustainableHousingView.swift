import SwiftUI

struct SustainableHousingView: View {
    @State private var zoom: CGFloat = 1

    var body: some View {
        GeometryReader { geometry in
            let mapWidth = min(geometry.size.width, geometry.size.height * 720 / 1100)
            let mapHeight = mapWidth * 1100 / 720

            ScrollView([.horizontal, .vertical]) {
                CityMapView()
                    .frame(width: mapWidth * zoom, height: mapHeight * zoom)
                    .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
            }
            .scrollIndicators(.hidden)
            .defaultScrollAnchor(.center)
            .background(Color(red: 0.89, green: 0.93, blue: 0.86))
            .overlay(alignment: .topLeading) {
                Label("City map", systemImage: "map")
                    .font(.subheadline.bold())
                    .foregroundStyle(Color(red: 0.16, green: 0.29, blue: 0.25))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.regularMaterial, in: Capsule())
                    .padding(16)
                    .allowsHitTesting(false)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            HStack {
                Spacer()
                CityMapControls(zoom: $zoom)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(Color(red: 0.89, green: 0.93, blue: 0.86))
        }
        .navigationTitle("Sustainable Housing")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct CityMapControls: View {
    @Binding var zoom: CGFloat

    var body: some View {
        HStack(spacing: 0) {
            Button {
                zoom = min(2.5, zoom + 0.5)
            } label: {
                Image(systemName: "plus")
                    .frame(width: 48, height: 48)
            }
            .accessibilityLabel("Zoom in")
            .disabled(zoom >= 2.5)

            Divider().frame(height: 28)

            Button {
                zoom = max(1, zoom - 0.5)
            } label: {
                Image(systemName: "minus")
                    .frame(width: 48, height: 48)
            }
            .accessibilityLabel("Zoom out")
            .disabled(zoom <= 1)

            Divider().frame(height: 28)

            Button {
                zoom = 1
            } label: {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .frame(width: 48, height: 48)
            }
            .accessibilityLabel("Show whole city")
        }
        .font(.body.weight(.semibold))
        .buttonStyle(.plain)
        .foregroundStyle(Color(red: 0.16, green: 0.29, blue: 0.25))
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.1), radius: 12, y: 4)
    }
}

private struct CityMapView: View {
    var body: some View {
        GeometryReader { geometry in
            let scale = geometry.size.width / 720

            ZStack(alignment: .topLeading) {
                CityMapArtwork()
                    .accessibilityHidden(true)

                ForEach(HousingLocation.allCases) { location in
                    NavigationLink {
                        HousingLocationDetailView(location: location)
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: location.symbol)
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.white)
                                .frame(width: 36, height: 36)
                                .background(location.color, in: Circle())
                                .overlay(Circle().strokeBorder(.white, lineWidth: 2))
                                .shadow(color: .black.opacity(0.12), radius: 4, y: 3)

                            Text(location.title)
                                .font(.caption.weight(.semibold))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Color(red: 0.12, green: 0.23, blue: 0.21))
                                .padding(.horizontal, 9)
                                .padding(.vertical, 6)
                                .background(.white.opacity(0.96), in: RoundedRectangle(cornerRadius: 10))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(width: 196 * scale, height: 270 * scale, alignment: .bottom)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .position(x: location.mapCenter.x * scale, y: location.mapCenter.y * scale)
                    .accessibilityLabel(Text(location.title))
                    .accessibilityHint("Opens this place")
                }
            }
            .environment(\.layoutDirection, .leftToRight)
        }
    }
}

#Preview {
    NavigationStack {
        SustainableHousingView()
    }
}
