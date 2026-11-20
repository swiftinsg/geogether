import AVFoundation
import SwiftUI

class SoundManager {
    static let shared = SoundManager()
    private var engine = AVAudioEngine()
    private var player = AVAudioPlayerNode()
    private let sampleRate: Double = 44100.0

    init() {
        setupAudio()
    }

    private func setupAudio() {
        engine.attach(player)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        engine.connect(player, to: engine.mainMixerNode, format: format)
        try? engine.start()
    }

    enum SoundEffect {
        case meow, purify, questComplete, quizCorrect, quizWrong, step
    }

    func play(_ effect: SoundEffect) {
        if !engine.isRunning { try? engine.start() }
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let duration: Double
        let startFreq: Double
        let endFreq: Double

        switch effect {
        case .meow: duration = 0.28; startFreq = 520; endFreq = 780
        case .purify: duration = 0.35; startFreq = 440; endFreq = 880
        case .questComplete: duration = 0.50; startFreq = 523.25; endFreq = 1046.50
        case .quizCorrect: duration = 0.25; startFreq = 600; endFreq = 900
        case .quizWrong: duration = 0.30; startFreq = 220; endFreq = 140
        case .step: duration = 0.04; startFreq = 180; endFreq = 120
        }

        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        let data = buffer.floatChannelData![0]
        var phase: Double = 0

        for i in 0..<Int(frameCount) {
            let progress = Double(i) / Double(frameCount)
            let currentFreq = startFreq + (endFreq - startFreq) * progress
            let envelope = sin(progress * .pi)
            phase += (2.0 * .pi * currentFreq) / sampleRate
            data[i] = Float(sin(phase) * envelope * 0.25)
        }

        player.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
        player.play()

        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: effect == .purify ? .heavy : .light)
        generator.impactOccurred()
        #endif
    }
}
