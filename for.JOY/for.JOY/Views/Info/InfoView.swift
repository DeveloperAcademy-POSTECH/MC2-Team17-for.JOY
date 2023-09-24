//
//  InfoView.swift
//  for.JOY
//
//  Created by hyebin on 2023/09/24.
//

import SwiftUI
import Photos

struct InfoView: View {
    @StateObject var realmManger = RealmManager.shared
    @ObservedObject var dataManager: DataManager
    @State private var title: String = ""
    @State private var date = Date()
    @State private var tag: String?
    @State private var isAddData: Bool = false
    @State private var pushBackButton = false
    @State private var showTagView = false

    let padding = UIScreen.height/844

    var body: some View {
        NavigationView {
            ZStack {
                Color.joyBlack
                    .ignoresSafeArea()

                VStack {
                    imageView()

                    VStack {
                        titleView()

                        Divider()

                        tagView()
                        Divider()
                        DatePicker(
                            "날짜",
                            selection: $date,
                            displayedComponents: [.date]
                        )
                        .tint(Color.joyBlue)
                    }
                    .padding()
                    .background(Color.joyWhite)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)

                }
                .background(Color.joyBlack)
                .foregroundColor(Color.black)
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: backButton)
                .navigationBarItems(trailing: doneButton)

                .alert("다시 녹음하시겠습니까?", isPresented: $pushBackButton, actions: {
                    Button("취소", role: .cancel) { }
                    Button("다시 녹음", role: .destructive) {
                        PageManger.shared.pageState = .voice
                    }
                }, message: {
                    Text("재녹음 시 이전에 녹음된 정보는 삭제됩니다.")
                })

                .sheet(isPresented: $showTagView) {
                    InfoTagView(selectTag: $tag, showTagView: $showTagView)
                }
                .keyboardAdaptive()
            }
        }
    }

    private var backButton: some View {
        Button {
            pushBackButton = true
        } label: {
            Text("\(Image(systemName: Images.chevronBack)) 다시 녹음")
                .foregroundColor(.joyBlue)
        }
    }

    private var doneButton: some View {
        Button {
            if !isAddData && title != "" {
                doneAction()
                isAddData = true
            }
        } label: {
            Text("완료")
                .foregroundColor(title == "" ? .gray : Color.joyBlue)
        }
        .disabled(title == "")
    }
}

extension InfoView {
    @ViewBuilder
    func imageView() -> some View {
        if let image = dataManager.imageData {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(CGSize(width: 3, height: 4), contentMode: .fill)
                .frame(width: 350*padding, height: 466*padding)
                .cornerRadius(10)
                .clipped()
                .padding(.horizontal, 15)
                .padding(.top, -30*padding)
                .padding(.bottom, 30*padding)
        } else {
            Image("test")
                .resizable()
                .aspectRatio(CGSize(width: 3, height: 4), contentMode: .fill)
                .frame(width: 350*padding, height: 466*padding)
                .cornerRadius(10)
                .clipped()
                .padding(.horizontal, 15)
                .padding(.top, -30*padding)
                .padding(.bottom, 30*padding)
        }
    }

    @ViewBuilder
    func titleView() -> some View {
        HStack {
            Text("제목")

            Spacer(minLength: 0)

            TextField("제목", text: $title)
                .font(.system(size: (17.0 - CGFloat(title.count)*0.3)))
                .multilineTextAlignment(.trailing)
                .onChange(of: title) { newValue in
                    title = String(newValue.prefix(20))
                }
        }
    }

    @ViewBuilder
    func tagView() -> some View {
        HStack {
            Text("태그")
                .frame(width: 60, alignment: .leading)

            Spacer(minLength: 0)

            Button(
                action: {
                    showTagView = true
                },
                label: {
                    if tag == nil {
                        Text("없음 \(Image(systemName: Images.chevronRight))")
                            .frame(maxWidth: 250, alignment: .trailing)
                            .foregroundColor(.black)
                    } else {
                        Text("\(tag!)\(Image(systemName: Images.chevronRight))")
                            .frame(maxWidth: 250, alignment: .trailing)
                            .foregroundColor(.black)
                    }
                }
            )
        }
    }
}

extension InfoView {
    func doneAction() {
        let year = Int(date.toString(dateFormat: "yyyy"))!
        let image = dataManager.imageData!.jpegData(compressionQuality: 0.8)!.base64EncodedString()
        let voice = dataManager.recording!.absoluteString

        realmManger.insertMemory(Memory(value: ["title": title, "year": year, "date": date, "tag": tag ?? "없음", "img": image, "voice": voice]))
        saveImage()

        dataManager.info = Info(
            title: title,
            year: Int16(year),
            date: date,
            tag: tag ?? "없음"
        )
        PageManger.shared.pageState = .addDone
    }

    func saveImage() {
        let albumName = "forJoy"

        guard let image = dataManager.imageData,
              let data = image.jpegData(compressionQuality: 1) else {
            return
        }

        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let folders = PHAssetCollection
            .fetchAssetCollections(
                with: .album,
                subtype: .albumRegular,
                options: fetchOptions
            )

        var albumFound = false
        folders.enumerateObjects { collection, _, stop in
            if let assetCollection = collection as? PHAssetCollection {
                albumFound = true
                saveImageToAlbum(imageData: data, album: assetCollection)
                stop.pointee = true
            }
        }

        if !albumFound {
            var albumPlaceholder: PHObjectPlaceholder?
            PHPhotoLibrary.shared().performChanges({
                let createAlbumRequest = PHAssetCollectionChangeRequest
                    .creationRequestForAssetCollection(withTitle: albumName)
                albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
            }, completionHandler: { success, error in
                if success, let placeholder = albumPlaceholder {
                    let createdAlbum = PHAssetCollection.fetchAssetCollections(
                        withLocalIdentifiers: [placeholder.localIdentifier],
                        options: nil
                    )

                    if let album = createdAlbum.firstObject {
                        saveImageToAlbum(imageData: data, album: album)
                    }
                } else if let error = error {
                    print("Error creating album: \(error.localizedDescription)")
                }
            })
        }
    }

    func saveImageToAlbum(imageData: Data, album: PHAssetCollection) {
        var placeholder: PHObjectPlaceholder?

        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAsset(from: UIImage(data: imageData)!)
            let assetPlaceholder = request.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
            albumChangeRequest?.addAssets([assetPlaceholder as Any] as NSArray)
            placeholder = assetPlaceholder
        }, completionHandler: { success, error in
            if success {
                print("Image saved to album")
            } else if let error = error {
                print("Error saving image: \(error.localizedDescription)")
            }
        })
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView(dataManager: DataManager())
    }
}

struct KeyboardAdaptiveModifier: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onAppear(perform: subscribeToKeyboardEvents)
            .onDisappear(perform: unsubscribeFromKeyboardEvents)
    }

    private func subscribeToKeyboardEvents() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardSize.height
            }
        }

        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            keyboardHeight = 0
        }
    }

    private func unsubscribeFromKeyboardEvents() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
}
