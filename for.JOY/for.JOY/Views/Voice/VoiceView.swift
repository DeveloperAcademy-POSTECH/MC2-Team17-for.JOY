//
//  VoiceView.swift
//  for.JOY
//
//  Created by hyebin on 2023/09/23.
//

import SwiftUI

struct VoiceView: View {
    @StateObject var voiceViewModel = VoiceViewModel()
    @ObservedObject var dataManager: DataManager

    let padding = UIScreen.height/844

    var topPadding: CGFloat {
        if #available(iOS 16.0, *) {
            return 0
        } else {
            return -1
        }
    }

    @State private var recording: URL?

    var body: some View {
        NavigationView {
            ZStack {
                Color.joyBlack
                    .ignoresSafeArea()

                VStack {
                    if let image = dataManager.imageData {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(CGSize(width: 3, height: 4), contentMode: .fill)
                            .frame(width: 350*padding, height: 466*padding)
                            .clipped()
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 30)
                            .padding(.top, 50*padding*topPadding)
                    }

                    SoundVisualizer()
                        .frame(width: 217 * padding, height: 35 * padding)
                        .opacity(voiceViewModel.isRecording && !voiceViewModel.isEndRecording ? 1 : 0)
                        .offset(y: voiceViewModel.isRecording && !voiceViewModel.isEndRecording ? 0 : -217 * padding)
                        .animation(.easeInOut(duration: 0.5))
                        .padding(.bottom, 20 * padding)

                    TimerView(viewModel: voiceViewModel, recording: $recording)
                        .frame(width: 57 * padding, height: 94 * padding)
                        .onChange(of: voiceViewModel.recording) { newValue in
                            dataManager.recording = newValue
                            recording = newValue
                        }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: backButton)
        }
    }

    private var backButton: some View {
        Button {
            PageManger.shared.pageState = .album
        } label: {
            Text("작성 취소")
                .foregroundColor(Color.joyBlue)
        }
    }
}

struct VoiceView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceView(dataManager: DataManager())
    }
}
