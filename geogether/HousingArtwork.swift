import SwiftUI

struct HousingArtwork: View {
    let location: HousingLocation

    var body: some View {
        Image(location.artworkName)
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .accessibilityHidden(true)
    }
}

struct HousingArtworkButton: View {
    let location: HousingLocation
    @State private var showsImage = false

    var body: some View {
        Button {
            showsImage = true
        } label: {
            HousingArtwork(location: location)
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.headline)
                        .padding(10)
                        .background(.regularMaterial, in: Circle())
                        .padding(12)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("Enlarge image: \(location.title)"))
        .accessibilityHint("Opens an image you can pinch to zoom")
        .fullScreenCover(isPresented: $showsImage) {
            HousingImageViewer(location: location)
        }
    }
}

struct HousingImageViewer: View {
    let location: HousingLocation
    @Environment(\.dismiss) private var dismiss
    @State private var zoom: CGFloat = 1
    @GestureState private var pinch: CGFloat = 1

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let scale = min(max(zoom * pinch, 1), 4)
                // Fit the full illustration before applying zoom; scroll in either direction.
                let width = min(geometry.size.width, geometry.size.height * 1.5)
                let height = width / 1.5

                ScrollView([.horizontal, .vertical]) {
                    Image(location.artworkName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: width * scale, height: height * scale)
                        .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                        .accessibilityLabel(Text(location.title))
                        .accessibilityZoomAction { action in
                            zoom = min(max(zoom + (action.direction == .zoomIn ? 0.5 : -0.5), 1), 4)
                        }
                }
                .simultaneousGesture(
                    MagnifyGesture()
                        .updating($pinch) { value, state, _ in
                            state = value.magnification
                        }
                        .onEnded { value in
                            zoom = min(max(zoom * value.magnification, 1), 4)
                        }
                )
                .onTapGesture(count: 2) {
                    zoom = zoom > 1 ? 1 : 2
                }
            }
            .background(.white)
            .navigationTitle(Text(location.title))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("Zoom out", systemImage: "minus.magnifyingglass") {
                        zoom = max(1, zoom - 0.5)
                    }
                    .disabled(zoom <= 1)

                    Spacer()

                    Button("Reset") { zoom = 1 }

                    Spacer()

                    Button("Zoom in", systemImage: "plus.magnifyingglass") {
                        zoom = min(4, zoom + 0.5)
                    }
                    .disabled(zoom >= 4)
                }
            }
        }
    }
}

