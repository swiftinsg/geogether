import SwiftUI

/// Small numbered capsule, used for ordering answers.
struct NumberBadge: View {
    let number: Int
    let tint: Color

    var body: some View {
        Text("\(number)")
            .font(.caption.weight(.bold))
            .foregroundStyle(tint)
            .frame(width: 22, height: 22)
            .background(Circle().fill(tint.opacity(0.18)))
    }
}
