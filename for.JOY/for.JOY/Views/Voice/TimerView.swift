//
//  TimerView.swift
//  for.JOY
//
//  Created by hyebin on 2023/09/24.
//

import AVFoundation
import SwiftUI

struct TimerView: View {
    @ObservedObject var viewModel: VoiceViewModel

    @State var remainingTime: TimeInterval = 180.0
    @State var settingTime =  180.0
    @State var recProgress: Double = 0.0
    @State var decibels: CGFloat = 0

    @State var timer2 = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @State private var animationTriggered = false

    @Binding var recording: URL?

    var audioRecorder: AVAudioRecorder = {
        guard  let audioRecordesr = try? AVAudioRecorder(
            url: FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            )[0].appendingPathComponent("audio.m4a"),
            settings: [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
        ) else {
            return AVAudioRecorder()
        }
        return audioRecordesr
    }()

    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    if !viewModel.isRecording && !viewModel.isEndRecording {
                        Button(
                            action: {
                                viewModel.startRecording()
                            }, label: {
                                Image(systemName: Images.startRecording)
                                    .font(.system(size: 48))
                                    .foregroundColor(Color.joyYellow)
                            }
                        )
                    } else if viewModel.isRecording && !viewModel.isEndRecording {
                        Button(
                            action: {
                                remainingTime = 0.0
                                recProgress = 1.0
                                viewModel.isRecording = false
                                viewModel.isEndRecording = true
                                viewModel.stopRecording()
                            }, label: {
                                Image(systemName: Images.stopRecording)
                                    .font(.system(size: 48))
                                    .foregroundColor(Color.joyGrey200)
                            }
                        )
                    } else if !viewModel.isRecording && viewModel.isEndRecording {
                        Image(systemName: Images.endRecording)
                            .font(.system(size: 48))
                            .foregroundColor(Color.joyBlue)
                            .onAppear {
                                animationTriggered = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    PageManger.shared.pageState = .info
                                }
                            }
                    }
                }
                .onAppear {
                    if viewModel.isRecording && !viewModel.isEndRecording {
                        setUpRecord()
                    }
                }
                .onDisappear {
                    if !viewModel.isRecording && viewModel.isEndRecording {
                        setEndRecord()
                    }
                }

                if !(viewModel.isEndRecording) {
                    Text(timeString(from: remainingTime))
                        .font(Font.body2)
                        .foregroundColor(Color.joyGrey200)
                        .padding(.top, 8)
                } else {
                    Text("")
                        .font(Font.body2)
                        .padding(.top, 8)
                }
            }
        }
        .onReceive(timer2) { _ in
            if !viewModel.isEndRecording {
                if viewModel.isRecording && remainingTime > 0 {
                    remainingTime -= 1
                    recProgress += (1/settingTime)
                } else if remainingTime <= 0 {
                    viewModel.isRecording = false
                    viewModel.isEndRecording = true
                    viewModel.stopRecording()
                }
            }
        }
    }

    func timeString(from time: TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func setUpRecord() {
        do {
            try? AVAudioSession.sharedInstance().setCategory(.record)
            try? AVAudioSession.sharedInstance().setActive(true)
            audioRecorder.prepareToRecord()
            audioRecorder.isMeteringEnabled = true
            audioRecorder.record()

            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                record()
            }
        }
    }

    func setEndRecord() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Error deactivating audio session:", error)
        }

        audioRecorder.isMeteringEnabled = false
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in

        }
    }

    func record() {
        audioRecorder.updateMeters()
        decibels = 100+CGFloat(audioRecorder.averagePower(forChannel: 0))
    }
}
