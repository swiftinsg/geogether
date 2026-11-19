import CoreGraphics
import Foundation
import Observation

@Observable
final class WaterCycleEngine {
    enum Phase: Int, CaseIterable, Identifiable {
        case evaporation, condensation, precipitation, collection

        var id: Self { self }

        var title: String {
            switch self {
            case .evaporation: "Evaporation"
            case .condensation: "Condensation"
            case .precipitation: "Precipitation"
            case .collection: "Collection"
            }
        }

        var numberedTitle: String { "\(rawValue + 1). \(title)" }
    }

    struct Particle: Identifiable {
        enum State { case sea, vapor, cloud, rain, runoff }

        let id: Int
        let lane: CGFloat
        let offset: CGFloat
        var state: State
        var progress: CGFloat
    }

    private enum CycleMode { case building, raining, collecting }

    static let particleCount = 300
    private static let saturatedCloudParticleCount = 180

    private(set) var particles: [Particle] = []
    private(set) var cloudMoisture: CGFloat = 0
    private(set) var phase = Phase.evaporation
    private(set) var completedCycles = 0
    var isPlaying = true
    var speed: CGFloat = 1

    @ObservationIgnored private var mode = CycleMode.building
    @ObservationIgnored private var lastUpdate: Date?
    @ObservationIgnored private var launchAccumulator: CGFloat = 0
    @ObservationIgnored private var rainAccumulator: CGFloat = 0
    @ObservationIgnored private var restartDelay: CGFloat = 0

    init() { reset() }

    var particleCount: Int { particles.count }

    func advance(to date: Date) {
        guard isPlaying else {
            lastUpdate = date
            return
        }
        guard let lastUpdate else {
            self.lastUpdate = date
            return
        }

        let elapsed = min(max(date.timeIntervalSince(lastUpdate), 0), 0.25)
        self.lastUpdate = date
        var remaining = CGFloat(elapsed) * speed
        while remaining > 0 {
            let timeStep = min(remaining, 1 / 60)
            step(by: timeStep)
            remaining -= timeStep
        }
    }

    func togglePlayback() {
        isPlaying.toggle()
        lastUpdate = nil
    }

    func toggleSpeed() {
        speed = speed == 1 ? 2 : 1
        lastUpdate = nil
    }

    func reset() {
        particles = (0..<Self.particleCount).map { index in
            Particle(
                id: index,
                lane: Self.unitValue(seed: index &* 73 &+ 19),
                offset: Self.unitValue(seed: index &* 151 &+ 47),
                state: .sea,
                progress: 0
            )
        }
        cloudMoisture = 0
        phase = .evaporation
        mode = .building
        launchAccumulator = 0
        rainAccumulator = 0
        restartDelay = 0
        completedCycles = 0
        lastUpdate = nil
    }

    func jump(to target: Phase) {
        reset()
        switch target {
        case .evaporation:
            for index in 0..<50 {
                particles[index].state = .vapor
                particles[index].progress = CGFloat(index % 10) / 12
            }
        case .condensation:
            for index in 0..<98 { particles[index].state = .cloud }
            for index in 98..<148 {
                particles[index].state = .vapor
                particles[index].progress = CGFloat(index % 12) / 13
            }
        case .precipitation:
            mode = .raining
            for index in 0..<160 { particles[index].state = .cloud }
            for index in 160..<205 {
                particles[index].state = .rain
                particles[index].progress = CGFloat(index % 15) / 16
            }
        case .collection:
            mode = .collecting
            for index in 0..<24 { particles[index].state = .cloud }
            for index in 24..<94 {
                particles[index].state = .rain
                particles[index].progress = CGFloat(index % 14) / 15
            }
            for index in 94..<214 {
                particles[index].state = .runoff
                particles[index].progress = CGFloat(index % 20) / 21
            }
        }
        updateCloudMoisture()
        phase = target
        lastUpdate = nil
    }

    private func step(by delta: CGFloat) {
        switch mode {
        case .building:
            launchAccumulator += delta * 46
            while launchAccumulator >= 1, launchOneVaporParticle() { launchAccumulator -= 1 }
        case .raining:
            releaseRain(at: 66, delta: delta)
        case .collecting:
            releaseRain(at: 42, delta: delta)
        }

        for index in particles.indices {
            switch particles[index].state {
            case .sea, .cloud:
                break
            case .vapor:
                particles[index].progress += delta * (0.24 + particles[index].offset * 0.07)
                if particles[index].progress >= 1 {
                    particles[index].state = .cloud
                    particles[index].progress = 0
                }
            case .rain:
                particles[index].progress += delta * (0.54 + particles[index].offset * 0.14)
                if particles[index].progress >= 1 {
                    particles[index].progress = 0
                    particles[index].state = particles[index].lane < 0.68 ? .runoff : .sea
                }
            case .runoff:
                particles[index].progress += delta * (0.27 + particles[index].offset * 0.10)
                if particles[index].progress >= 1 {
                    particles[index].state = .sea
                    particles[index].progress = 0
                }
            }
        }
        updateCloudMoisture()
        updatePhase(by: delta)
    }

    private func updatePhase(by delta: CGFloat) {
        switch mode {
        case .building:
            phase = cloudMoisture < 0.34 ? .evaporation : .condensation
            if cloudMoisture >= 0.85 {
                mode = .raining
                phase = .precipitation
                rainAccumulator = 0
            }
        case .raining:
            phase = .precipitation
            if cloudMoisture <= 0.14 {
                mode = .collecting
                phase = .collection
            }
        case .collecting:
            phase = .collection
            if particles.allSatisfy({ $0.state == .sea }) {
                restartDelay += delta
                if restartDelay >= 0.65 {
                    mode = .building
                    phase = .evaporation
                    restartDelay = 0
                    completedCycles += 1
                }
            } else {
                restartDelay = 0
            }
        }
    }

    private func launchOneVaporParticle() -> Bool {
        guard let index = particles.firstIndex(where: { $0.state == .sea }) else { return false }
        particles[index].state = .vapor
        particles[index].progress = 0
        return true
    }

    private func releaseRain(at rate: CGFloat, delta: CGFloat) {
        rainAccumulator += delta * rate
        while rainAccumulator >= 1,
              let index = particles.firstIndex(where: { $0.state == .cloud }) {
            particles[index].state = .rain
            particles[index].progress = 0
            rainAccumulator -= 1
        }
    }

    private func updateCloudMoisture() {
        let count = particles.reduce(into: 0) { count, particle in
            if particle.state == .cloud { count += 1 }
        }
        cloudMoisture = min(CGFloat(count) / CGFloat(Self.saturatedCloudParticleCount), 1)
    }

    private static func unitValue(seed: Int) -> CGFloat {
        var value = UInt64(truncatingIfNeeded: seed)
        value = value &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return CGFloat(value % 10_000) / 9_999
    }
}
