//
//  VoiceView.swift
//  for.JOY
//
//  Created by hyebin on 2023/09/23.
//

import SwiftUI

struct VoiceView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var voiceViewModel = VoiceViewModel()

    let padding = UIScreen.height/844

    //TODO: DataManager로 빼기
    @State private var recording: URL?
    //    private var selectedImage: UIImage? = UIImage(named: "test")

//    @Binding var recording: URL?

    var body: some View {
        NavigationView {
            ZStack {
                Color.joyBlack
                    .ignoresSafeArea()

                VStack {
                    if let image = UIImage(named: "test") {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(CGSize(width: 3, height: 4), contentMode: .fill)
                            .frame(width: 350*padding, height: 466*padding)
                            .clipped()
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 30)
                    }

//                    SoundVisualizer()
//                        .frame(width: 217 * padding, height: 35 * padding)
//                        .opacity(voiceViewModel.isRecording && !voiceViewModel.isEndRecording ? 1 : 0)
//                        .offset(y: voiceViewModel.isRecording && !voiceViewModel.isEndRecording ? 0 : -50)
//                        .animation(.easeInOut(duration: 0.5))
//                        .padding(.bottom, 20 * padding)

                    TimerView(viewModel: voiceViewModel, recording: $recording)
                        .frame(width: 57 * padding, height: 94 * padding)
                        .onChange(of: voiceViewModel.recording) { newValue in
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
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text("작성 취소")
                .foregroundColor(Color.joyBlue)
        }
    }
}

struct VoiceView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceView()
    }
}
