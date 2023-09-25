//
//  VoiceView.swift
//  for.JOY
//
//  Created by hyebin on 2023/09/23.
//

import SwiftUI

struct VoiceView: View {
    @StateObject var permissionHandler = PermissionHandler()
    @StateObject var voiceViewModel = VoiceViewModel()
    @ObservedObject var dataManager: DataManager

    @State private var recording: URL?
    @State private var showPermissionAlert = false

    let padding = UIScreen.height/844

    var topPadding: CGFloat {
        if #available(iOS 16.0, *) {
            return 0
        } else {
            return -1
        }
    }

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
                        .padding(.top, 10)
                        .padding(.bottom, 20 * padding)

                    TimerView(viewModel: voiceViewModel, recording: $recording)
                        .frame(width: 57 * padding, height: 94 * padding)
                        .onChange(of: voiceViewModel.recording) { newValue in
                            dataManager.recording = newValue
                            recording = newValue
                        }
                }
                .onAppear {
                    permissionHandler.checkAudioPermission { granted in
                        if !granted {
                            showPermissionAlert = true
                        }
                    }
                }
                .alert(isPresented: $showPermissionAlert) {
                    let title = "마이크 권한이 거부되었습니다"
                    let message = "설정에서 마이크 권한을 허용해 주세요"

                    return Alert(
                        title: Text(title),
                        message: Text(message),
                        dismissButton: .default(Text("OK")) {
                            showPermissionAlert = false
                            PageManger.shared.pageState = .album
                        }
                    )
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
