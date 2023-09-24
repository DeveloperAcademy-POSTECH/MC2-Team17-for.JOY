//
//  CarouselView.swift
//  for.JOY
//
//  Created by hyebin on 2023/09/23.
//

import SwiftUI
import RealmSwift

struct CarouselView: View {
    @StateObject var realmManager = RealmManager.shared
//    @State private var fakedMemories: [Memory] = []
//    @State private var offset = 0.0
    @State private var isShowAlert = false
    @State private var yearlyMemories: [Memory] = []
    @State var isPlaying = false
    @State var currentIndex: ObjectId = .init()
    let year = 2023
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
//                guard fakedMemories.isEmpty else { return }
                yearlyMemories = realmManager.yearlyMemories[year]!
                currentIndex = yearlyMemories.first!.id
            }
            .alert(Texts.deleteAlertCheck, isPresented: $isShowAlert,
                   actions: {
                Button(Texts.cancelButtonLabel, role: .cancel) {
                    isShowAlert = false
                }
                Button(Texts.deleteButtonLabel, role: .destructive) {
                    var index = originIndex(currentIndex)
                    if index == yearlyMemories.count - 1 {
                        index = 0
                    }
                    realmManager.deleteMemory(currentIndex)
                    realmManager.selectYealryMemories()
                    yearlyMemories = realmManager.yearlyMemories[year] ?? []
//                    fakedMemories = yearlyMemories
                    if yearlyMemories.isEmpty {
                        PageManger.shared.pageState = .gallery
                    } else {
                        currentIndex = yearlyMemories[index].id
                    }
                }
            }, message: {
                Text(Texts.deleteAlertDescription)
            })
            .navigationBarItems(leading: backButton())
            .navigationBarItems(trailing: editButton())
        }
    }
//    func fakeIndex(_ of: Memory) -> Int {
//        return fakedMemories.firstIndex(of: of) ?? 0
//    }
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
            PageManger.shared.pageState = .album
        } label: {
            Image(systemName: Images.chevronBack)
                .foregroundColor(Color.joyBlue)
        }
    }
    @ViewBuilder
    func editButton() -> some View {
        Menu {
            Button {
                // TODO: EditInfoView() 생성 후 추가
                PageManger.shared.pageState = .info
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
        GeometryReader {
            let size = $0.size
            TabView(selection: $currentIndex) {
                ForEach(yearlyMemories, id: \.id) { memory in
                    if !memory.isInvalidated {
                        VStack(spacing: 7) {
                            Image(Images.emptyMemory)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
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
                                    isPlaying.toggle()
                                } label: {
                                    Circle()
                                        .frame(width: 50)
                                        .foregroundColor(isPlaying ? Color.joyYellow : Color.joyGrey100)
                                        .overlay {
                                            Image(systemName: isPlaying ? Images.pause : Images.play)
                                                .foregroundColor(isPlaying ? Color.joyWhite : Color.joyBlue)
                                        }
                                }
                                .padding(.trailing, 20)
                            }
                        }
                        .padding(.bottom, 21)
                        .frame(width: cardWidth, height: cardHeight)
                        .background(Color.joyWhite)
                        .cornerRadius(20)
                        .shadow(radius: 4)
                        .tag(memory.id)
//                        .offsetX(currentIndex == memory.id) { rect in
//                            let minX = rect.minX
//                            let pageOffset = minX - (size.width * CGFloat(fakeIndex(memory)))
//                            let pageProgress = pageOffset / size.width
//                            if -pageProgress < 1.0 {
//                                if fakedMemories.indices.contains(fakedMemories.count - 1) {
//                                    currentIndex = fakedMemories[fakedMemories.count - 1].id
//                                }
//                            }
//                            if -pageProgress > CGFloat(fakedMemories.count - 1) {
//                                if fakedMemories.indices.contains(1) {
//                                    currentIndex = fakedMemories[1].id
//                                }
//                            }
//                        }
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
//            .onAppear {
//                fakedMemories.append(contentsOf: yearlyMemories)
//                guard var first = yearlyMemories.first else { return }
//                guard var last = yearlyMemories.last else { return }
//                currentIndex = first.id
//                fakedMemories.append(first)
//                fakedMemories.insert(last, at: 0)
//            }
        }
    }
    @ViewBuilder
    func pageNumbering() -> some View {
        Text("\(originIndex(currentIndex) + 1) / \(yearlyMemories.count)")
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
        CarouselView()
    }
}
