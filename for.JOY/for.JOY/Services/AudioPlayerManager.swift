//
//  AudioPlayer.swift
//  for.JOY
//
//  Created by Nayeon Kim on 2023/09/24.
//

import Foundation
import AVFoundation

class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    var audioPlayer: AVAudioPlayer?
    @Published var isPlaying = false
    @Published var isPaused = false
}

extension AudioPlayerManager {
    func startPlaying(recordingURL: URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[Audio/Error] Failed to set active")
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: recordingURL)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            self.isPlaying = true
            self.isPaused = false
        } catch {
            print("[Audio/Error] Failed to play")
        }
    }
    func pausePlaying() {
        audioPlayer?.pause()
        self.isPaused = true
    }
    func resumePlaying() {
        audioPlayer?.play()
        self.isPaused = false
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.isPlaying = false
        self.isPaused = false
    }
}
