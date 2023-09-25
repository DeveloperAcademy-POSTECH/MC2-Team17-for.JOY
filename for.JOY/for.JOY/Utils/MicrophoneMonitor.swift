//
//  MicrophoneMonitor.swift
//  for.JOY
//
//  Created by hyebin on 2023/09/24.
//

import Foundation
import AVFoundation

class MicrophoneMonitor: ObservableObject {
    private var svAudioRecorder: AVAudioRecorder
    private var svTimer: Timer?

    private var svCurrentSample: Int
    private let svNumberOfSamples: Int

    @Published public var svSoundSamples: [Float]

    init(numberOfSamples: Int) {
        self.svNumberOfSamples = numberOfSamples
        self.svSoundSamples = [Float](repeating: -160, count: numberOfSamples)
        self.svCurrentSample = 0

        let audioSession = AVAudioSession.sharedInstance()

        let url = URL(fileURLWithPath: "/dev/null", isDirectory: true)
        let recorderSettings: [String: Any] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatAppleLossless),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
        ]

        do {
            svAudioRecorder = try AVAudioRecorder(url: url, settings: recorderSettings)
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [])

            svStartMonitoring()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    private func svStartMonitoring() {
        svAudioRecorder.isMeteringEnabled = true
        svAudioRecorder.record()
        svTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { _ in
            self.svAudioRecorder.updateMeters()
            self.svSoundSamples.removeFirst()
            self.svSoundSamples.append(self.svAudioRecorder.averagePower(forChannel: 0))
        })
    }

    deinit {
        svTimer?.invalidate()
        svAudioRecorder.stop()
    }
}
