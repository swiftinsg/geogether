import SwiftUI

struct WaterCycleView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var engine = WaterCycleEngine()
    @State private var showProcessPopup = true

    private var phases: [WaterCycleEngine.Phase] {
        Array(WaterCycleEngine.Phase.allCases)
    }

    private var currentPhaseIndex: Int {
        phases.firstIndex(of: engine.phase) ?? 0
    }

    private var canGoPrevious: Bool {
        currentPhaseIndex > 0
    }

    private var nextPhase: WaterCycleEngine.Phase? {
        let nextIndex = currentPhaseIndex + 1
        guard phases.indices.contains(nextIndex) else { return nil }
        return phases[nextIndex]
    }

    private var previousPhase: WaterCycleEngine.Phase? {
        let prevIndex = currentPhaseIndex - 1
        guard phases.indices.contains(prevIndex) else { return nil }
        return phases[prevIndex]
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            simulationStage
        }
        .background(Color(red: 0.91, green: 0.97, blue: 1))
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: engine.phase) { _ in
            showProcessPopup = true
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.headline.weight(.bold))
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(.white.opacity(0.88)))
            }
            .accessibilityLabel("Back")

            Text("Water distribution")
                .font(.system(.title3, design: .rounded).weight(.bold))
                .foregroundStyle(AppPalette.navy)

            Spacer()

            Text("\(engine.particleCount) drops")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppPalette.navy.opacity(0.72))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var simulationStage: some View {
        TimelineView(.animation(minimumInterval: 1 / 30, paused: !engine.isPlaying)) { timeline in
            ZStack {
                Canvas(opaque: true, colorMode: .linear, rendersAsynchronously: false) { context, size in
                    WaterCycleRenderer.draw(
                        context: &context,
                        size: size,
                        particles: engine.particles,
                        cloudMoisture: engine.cloudMoisture,
                        phase: engine.phase,
                        time: timeline.date.timeIntervalSinceReferenceDate
                    )
                }
                .onChange(of: timeline.date) { date in
                    engine.advance(to: date)
                }
                .onAppear {
                    engine.advance(to: timeline.date)
                }

                VStack(spacing: 8) {
                    HStack {
                        phasePill
                        Spacer()
                    }

                    Spacer()

                    if showProcessPopup {
                        processPopupCard
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    phaseButtons
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Water cycle simulation")
        .accessibilityValue(engine.phase.numberedTitle)
    }

    private var phasePill: some View {
        Button {
            withAnimation(.snappy(duration: 0.22)) {
                showProcessPopup.toggle()
            }
        } label: {
            HStack(spacing: 6) {
                Label(engine.phase.numberedTitle, systemImage: phaseSymbol)
                    .font(.caption.weight(.bold))
                Image(systemName: showProcessPopup ? "info.circle.fill" : "info.circle")
                    .font(.caption2.weight(.semibold))
                    .opacity(0.85)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(AppPalette.navy.opacity(0.9))
                    .shadow(color: .black.opacity(0.14), radius: 8, y: 3)
            )
            .contentTransition(.numericText())
            .animation(.snappy, value: engine.phase)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(engine.phase.numberedTitle), \(showProcessPopup ? "hide" : "show") explanation")
    }

    private var processPopupCard: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .center, spacing: 8) {
                Text("Step \(currentPhaseIndex + 1)/\(phases.count)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(AppPalette.navy))

                Text(engine.phase.popupTitle)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppPalette.navy)

                Spacer()

                Button {
                    withAnimation(.snappy(duration: 0.2)) {
                        showProcessPopup = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 24, height: 24)
                        .background(Circle().fill(.black.opacity(0.06)))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Dismiss explanation")
            }

            Text(engine.phase.explanation)
                .font(.caption)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                Button {
                    goToPreviousProcess()
                } label: {
                    Label("Previous", systemImage: "chevron.left")
                        .font(.caption2.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(canGoPrevious ? Color.white.opacity(0.88) : Color.white.opacity(0.38))
                        )
                        .foregroundStyle(canGoPrevious ? AppPalette.navy : .secondary)
                }
                .buttonStyle(.plain)
                .disabled(!canGoPrevious)

                Button {
                    continueToNextProcess()
                } label: {
                    HStack(spacing: 4) {
                        Text(nextPhase != nil ? "Continue" : "Restart")
                        Image(systemName: nextPhase != nil ? "chevron.right" : "arrow.counterclockwise")
                    }
                    .font(.caption2.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(AppPalette.navy)
                    )
                    .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(.white.opacity(0.65), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.14), radius: 10, y: 4)
        )
    }

    private var phaseButtons: some View {
        HStack(spacing: 6) {
            ForEach(WaterCycleEngine.Phase.allCases) { phase in
                Button {
                    engine.jump(to: phase)
                    withAnimation(.snappy(duration: 0.22)) {
                        showProcessPopup = true
                    }
                } label: {
                    Text("\(phase.rawValue + 1)")
                        .font(.caption2.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(engine.phase == phase ? .white : .white.opacity(0.62)))
                        .foregroundStyle(engine.phase == phase ? AppPalette.navy : .secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(phase.numberedTitle)
                .accessibilityHint("Jump to this stage")
            }
        }
        .padding(5)
        .background(.ultraThinMaterial, in: Capsule())
    }

    private func goToPreviousProcess() {
        guard let previousPhase else { return }
        engine.jump(to: previousPhase)
        withAnimation(.snappy(duration: 0.22)) {
            showProcessPopup = true
        }
    }

    private func continueToNextProcess() {
        if let nextPhase {
            engine.jump(to: nextPhase)
        } else if let firstPhase = phases.first {
            engine.jump(to: firstPhase)
        }
        withAnimation(.snappy(duration: 0.22)) {
            showProcessPopup = true
        }
    }

    private var phaseSymbol: String {
        switch engine.phase {
        case .evaporation: "arrow.up"
        case .condensation: "cloud.fill"
        case .precipitation: "cloud.rain.fill"
        case .collection: "water.waves"
        }
    }
}

#Preview {
    NavigationStack { WaterCycleView() }
}
