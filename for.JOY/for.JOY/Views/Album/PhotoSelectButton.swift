//
//  PhotoSelectButton.swift
//  for.JOY
//
//  Created by hyebin on 2023/09/23.
//

import SwiftUI

struct PhotoSelectButton: View {
    @State private var isShowActionSheet = false
    @State private var isShowingCameraPicker = false
    @State private var isShowingPhotoLibraryPicker = false
    @State private var isShowingCropView = false

    @State private var selectedImage: UIImage?
    @State private var croppedImage: UIImage?

    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                LinearGradient(colors: [Color.joyBlack.opacity(0), Color.joyBlack], startPoint: .top, endPoint: .bottom)

                createMemoryButton()
                    .actionSheet(isPresented: $isShowActionSheet) {
                        ActionSheet(
                            title: Text(Texts.cameraActionSheetTitle),
                                buttons: [
                                    .default(Text(Texts.cameraActionSheetCamera)) {
                                        isShowingCameraPicker = true
                                    },
                                    .default(Text(Texts.cameraActionSheetLibrary)) {
                                        isShowingPhotoLibraryPicker = true
                                    },
                                    .cancel()
                                ]
                        )
                    }
                    .fullScreenCover(
                        isPresented: $isShowingCameraPicker
                    ) {
                        ImagePickerView(
                            selectedImage: $selectedImage,
                            sourceType: .camera
                        )
                        .ignoresSafeArea()
                    }
                    .sheet(
                        isPresented: $isShowingPhotoLibraryPicker
                    ) {
                        ImagePickerView(selectedImage: $selectedImage, sourceType: .photoLibrary)
                            .accentColor(.joyBlue)
                            .ignoresSafeArea()
                            .preferredColorScheme(.dark)
                    }
                    .sheet(isPresented: $isShowingCropView) {
                        isShowingCropView = false
                        isShowingCameraPicker = false
                        isShowingPhotoLibraryPicker = false
                    } content: {
                        ImageCropView(
                            image: selectedImage,
                            showCropView: $isShowingCropView
                        ) { croppedImage, _ in
                            if let croppedImage {
                                self.croppedImage = croppedImage
                            }
                        }
                    }
            }

            Rectangle()
                .foregroundColor(Color.joyBlack)
                .frame(height: UIScreen.height * 0.04)
        }
        .frame(height: UIScreen.height * 0.15)
        .onChange(of: selectedImage) { _ in
            isShowingCropView.toggle()
        }
        .onChange(of: croppedImage) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                PageManger.shared.pageState = .voice
            }
        }
    }
}

extension PhotoSelectButton {
    @ViewBuilder
    func createMemoryButton() -> some View {
        Button(
            action: {
                isShowActionSheet = true
            }, label: {
                HStack {
                    Image(systemName: Images.plus)
                    Text(Texts.createMemoryButton)
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(Color.joyBlack)
                .font(Font.body1Kor)
                .padding(.vertical, 18)
                .padding(.horizontal, 16)
                .background(Color.joyYellow)
                .cornerRadius(16)
            }
        )
        .padding(.horizontal, 16)
    }
}

struct PhotoSelectButton_Previews: PreviewProvider {
    static var previews: some View {
        PhotoSelectButton()
    }
}
