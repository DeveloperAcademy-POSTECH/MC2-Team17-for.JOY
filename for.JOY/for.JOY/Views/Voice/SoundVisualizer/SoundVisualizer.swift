//
//  SoundVisualizer.swift
//  for.JOY
//
//  Created by hyebin on 2023/09/24.
//

import SwiftUI

struct SoundVisualizer: View {
    static let svNumberOfSamples: Int = 80
    @StateObject private var mic = MicrophoneMonitor(numberOfSamples: svNumberOfSamples)

    var body: some View {
        VStack {
            HStack(spacing: 3) {
                ForEach(mic.svSoundSamples.indices, id: \.self) { index in
                    BarView(value: self.svNormalizeSoundLevel( mic.svSoundSamples[index]), index: index)
                }
            }
            .frame(width: 218, height: 35)
            .clipped()
        }
    }

    private func svNormalizeSoundLevel(_ level: Float) -> CGFloat {
        let level = max(0.2, CGFloat(level) + 50) / 10
        return CGFloat(level * (150 / 25))
    }
}

struct SoundVisualizer_Previews: PreviewProvider {
    static var previews: some View {
        SoundVisualizer()
    }
}
