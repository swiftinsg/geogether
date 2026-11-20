import SwiftUI

struct SimulationCard: View {
    let destination: SimulationDestination

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(destination.tint.opacity(0.16))
                Image(systemName: destination.symbol)
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundStyle(destination.tint)
            }
            .frame(width: 58, height: 58)

            VStack(alignment: .leading, spacing: 5) {
                Text(destination.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(destination.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 4)

            Image(systemName: "play.circle.fill")
                .font(.title2)
                .foregroundStyle(destination.tint)
        }
        .padding(17)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .shadow(color: .black.opacity(0.06), radius: 16, y: 7)
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityHint(destination == .geoWorld ? "Opens GeogWorld" : "Opens the simulation")
    }
}
