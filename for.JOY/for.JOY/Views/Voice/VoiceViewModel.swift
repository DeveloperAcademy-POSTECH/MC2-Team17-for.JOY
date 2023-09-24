//
//  VoiceViewModel.swift
//  for.JOY
//
//  Created by hyebin on 2023/09/24.
//

import SwiftUI
import AVFoundation

class VoiceViewModel: NSObject, ObservableObject {
    @Published var isRecording: Bool = false
    @Published var isEndRecording: Bool = false
    @Published var recording: URL?
    @Published var countSec = 0
    @Published var timerCount: Timer?
    @Published var blinkingCount: Timer?
    @Published var timer: String = "0:00"
    @Published var toggleColor: Bool = false

    var audioRecorder: AVAudioRecorder!

    // 녹음 시작 메소드
    func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Cannot setup the Recording")
        }

        guard let path = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.for.helia")
        else {
            print("Failed to access app group identifier")
            return
        }

        recording = path.appendingPathComponent("\(Date().toString(dateFormat: "YY-MM-dd-HH-mm-ss")).m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: recording!, settings: settings)
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            isRecording = true
            isEndRecording = false

            timerCount = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                self.countSec += 1
                self.timer = self.covertSecToMinAndHour(seconds: self.countSec)
            })

            blinkColor()
        } catch {
            print("Failed to Setup the Recording")
        }
    }

    // 녹음 중지 메소드
    func stopRecording() {
        audioRecorder.stop()
        isRecording = false
        isEndRecording = true
        self.countSec = 0
        timerCount!.invalidate()
        blinkingCount!.invalidate()
    }

    // 타이머, 일정한 시간 간격으로 toggleColor를 변경
    func blinkColor() {
        blinkingCount = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true, block: { _ in
            self.toggleColor.toggle()
        })
    }
}

extension VoiceViewModel {
    func covertSecToMinAndHour(seconds: Int) -> String {
        let (_, minute, second) = (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        let sec: String = second < 10 ? "0\(second)" : "\(second)"
        return "\(minute):\(sec)"
    }
}
