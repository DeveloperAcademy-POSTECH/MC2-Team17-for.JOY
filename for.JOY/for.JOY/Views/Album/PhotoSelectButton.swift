//
//  PhotoSelectButton.swift
//  for.JOY
//
//  Created by hyebin on 2023/09/23.
//

import SwiftUI

struct PhotoSelectButton: View {
    @StateObject var permissionHandler = PermissionHandler()

    @ObservedObject var dataManager: DataManager
    @State private var isShowActionSheet = false
    @State private var isShowingCameraPicker = false
    @State private var isShowingPhotoLibraryPicker = false
    @State private var isShowingCropView = false

    @State private var selectedImage: UIImage?
    @State private var croppedImage: UIImage?

    @State private var cameraPermission = false
    @State private var photoLibraryPermission = false
    @State private var showPermissionAlert = false

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
                                        permissionHandler.checkCameraPermission { granted in
                                            if granted {
                                                isShowingCameraPicker = true
                                            } else {
                                                cameraPermission = true
                                                showPermissionAlert = true
                                            }
                                        }
                                    },
                                    .default(Text(Texts.cameraActionSheetLibrary)) {
                                        permissionHandler.checkPhotoLibraryPermission { granted in
                                            if granted {
                                                isShowingPhotoLibraryPicker = true
                                            } else {
                                                photoLibraryPermission = true
                                                showPermissionAlert = true
                                            }
                                        }
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
                    .alert(isPresented: $showPermissionAlert) {
                        let title = cameraPermission ? "카메라에 접근할 수 없습니다." : "사진에 접근할 수 없습니다."
                        let message = cameraPermission ? "설정에서 \"카메라\" 권한을 허용해 주세요." : "설정에서 \"사진\" 권한을 허용해 주세요."

                        return Alert(
                            title: Text(title),
                            message: Text(message),
                            dismissButton: .default(Text("OK")) {
                                cameraPermission = false
                                photoLibraryPermission = false
                            }
                        )
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
            dataManager.imageData = croppedImage
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
        PhotoSelectButton(dataManager: DataManager())
    }
}
