//
//  CarouselView.swift
//  for.JOY
//
//  Created by hyebin on 2023/09/23.
//

import SwiftUI
import RealmSwift
import AVFoundation

struct CarouselView: View {
    @StateObject var realmManager = RealmManager.shared
    @ObservedObject var dataManager: DataManager
    @StateObject var audioPlayerManager = AudioPlayerManager()
    @State private var isShowAlert = false
    @State private var isShowEditSheet = false
    @State private var yearlyMemories: [Memory] = []
    @State var currentId: ObjectId = .init()
    private let cardWidth = UIScreen.width - 70
    private let cardHeight = (UIScreen.width - 104) / 3 * 4 + 132
    private let imageWidth = UIScreen.width - 104
    var body: some View {
        NavigationView {
            ZStack {
                Color.joyBlack
                    .ignoresSafeArea()
                VStack {
                    carouselMainView()
                    pageNumbering()
                    Spacer()
                }
            }
            .onAppear {
                DispatchQueue.main.async {
                    currentId = dataManager.selectedId!
                    let year = dataManager.selectedYear!
                    yearlyMemories = realmManager.yearlyMemories[year]!
                }
            }
            .alert(Texts.deleteAlertCheck, isPresented: $isShowAlert,
                   actions: {
                Button(Texts.cancelButtonLabel, role: .cancel) {
                    isShowAlert = false
                }
                Button(Texts.deleteButtonLabel, role: .destructive) {
                    let year = dataManager.selectedYear!
                    let tag = dataManager.selectedTag
                    var index = originIndex(currentId)
                    if index == yearlyMemories.count - 1 {
                        index = 0
                    }
                    realmManager.deleteMemory(currentId)
                    if tag != nil {
                        realmManager.selectYealryMemories(tag!)
                    } else {
                        realmManager.selectYealryMemories()
                    }
                    yearlyMemories = realmManager.yearlyMemories[year] ?? []
                    if yearlyMemories.isEmpty {
                        PageManger.shared.pageState = .gallery
                    } else {
                        currentId = yearlyMemories[index].id
                    }
                }
            }, message: {
                Text(Texts.deleteAlertDescription)
            })
            .navigationBarItems(leading: backButton())
            .navigationBarItems(trailing: editButton())
        }
    }
    func originIndex(_ id: ObjectId) -> Int {
        return yearlyMemories.firstIndex { page in
            page.id == id
        } ?? 0
    }
}

extension CarouselView {
    @ViewBuilder
    func backButton() -> some View {
        Button {
            PageManger.shared.pageState = .gallery
        } label: {
            Image(systemName: Images.chevronBack)
                .foregroundColor(Color.joyBlue)
        }
    }
    @ViewBuilder
    func editButton() -> some View {
        Menu {
            Button {
                self.isShowEditSheet = true
            } label: {
                HStack {
                    Text(Texts.editButtonLabel)
                    Spacer()
                    Image(systemName: Images.edit)
                }
            }
            Button(role: .destructive) {
                isShowAlert = true
            } label: {
                HStack {
                    Text(Texts.deleteButtonLabel)
                    Spacer()
                    Image(systemName: Images.delete)
                }
            }
        } label: {
            Image(systemName: Images.more)
                .foregroundColor(Color.joyBlue)
        }
    }
    @ViewBuilder
    func carouselMainView() -> some View {
        TabView(selection: $currentId) {
            ForEach(yearlyMemories, id: \.id) { memory in
                if !memory.isInvalidated {
                    VStack(spacing: 7) {
                        Image(uiImage: UIImage(data: Data(base64Encoded: memory.img)!) ?? UIImage(named: Images.emptyMemory)!)
                            .resizable()
                            .frame(width: 350, height: 466)
                            .frame(width: imageWidth, height: imageWidth / 3 * 4)
                            .clipped()
                            .cornerRadius(10)
                            .shadow(radius: 3)
                            .padding(17)
                        HStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(memory.title)
                                    .font(Font.body1Kor)
                                    .foregroundColor(Color.joyBlack)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                                Text(memory.date.toString(dateFormat: "yyyy.MM.dd"))
                                    .font(Font.body2)
                                    .foregroundColor(Color.joyGrey200)
                            }
                            .padding(.leading, 27)
                            Spacer()
                            Button {
                                let url = URL(string: memory.voice)!
                                if audioPlayerManager.isPlaying && audioPlayerManager.audioPlayer?.url == url {
                                    audioPlayerManager.isPaused ? audioPlayerManager.resumePlaying() : audioPlayerManager.pausePlaying()
                                } else {
                                    audioPlayerManager.startPlaying(recordingURL: url)
                                }
                            } label: {
                                Circle()
                                    .frame(width: 50)
                                    .foregroundColor(audioPlayerManager.isPlaying && !audioPlayerManager.isPaused ? Color.joyYellow : Color.joyGrey100)
                                    .overlay {
                                        Image(systemName: audioPlayerManager.isPlaying && !audioPlayerManager.isPaused ? Images.pause : Images.play)
                                            .foregroundColor(audioPlayerManager.isPlaying ? Color.joyWhite : Color.joyBlue)
                                    }
                            }
                            .padding(.trailing, 20)
                        }
                    }
                    .onAppear {
                        audioPlayerManager.isPlaying = false
                        audioPlayerManager.isPaused = false
                        audioPlayerManager.audioPlayer?.stop()
                    }
                    .fullScreenCover(isPresented: $isShowEditSheet) {
                        EditInfoView(realmManager: realmManager, selectedData: memory)
                    }
                    .tag(memory.id)
                    .padding(.bottom, 21)
                    .frame(width: cardWidth, height: cardHeight)
                    .background(Color.joyWhite)
                    .cornerRadius(20)
                    .shadow(radius: 4)
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
    @ViewBuilder
    func pageNumbering() -> some View {
        Text("\(originIndex(currentId) + 1) / \(yearlyMemories.count)")
            .font(Font.body3)
            .foregroundColor(Color.joyWhite)
            .background(
                Capsule()
                    .fill(Color.joyGrey300)
                    .frame(width: 80, height: 30)
            )
    }
}

struct CarouselView_Previews: PreviewProvider {
    static var previews: some View {
        CarouselView(dataManager: DataManager())
    }
}
