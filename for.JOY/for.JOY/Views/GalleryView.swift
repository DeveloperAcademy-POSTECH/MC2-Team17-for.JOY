//
//  GalleryView.swift
//  for.JOY
//
//  Created by hyebin on 2023/09/23.
//

import SwiftUI

struct GalleryView: View {
    @StateObject var realmManager = RealmManager.shared
    @ObservedObject var dataManager: DataManager
    @State private var isNewest = true
    @State private var yearlyMemories: [Memory] = []
    var columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 4.5), count: 3)
    private let imageSize = (UIScreen.width - 9) / 3
    var body: some View {
        NavigationView {
            ZStack {
                Color.joyBlack
                    .ignoresSafeArea()
                VStack {
                    Text(setAlbumName())
                        .font(Font.largeTitleKor)
                        .foregroundColor(Color.joyWhite)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 10)
                        .padding(.leading)
                    galleryMainView()
                }
            }
            .onAppear {
                let year = dataManager.selectedYear!
                yearlyMemories = realmManager.yearlyMemories[year] ?? []
            }
            .navigationBarItems(leading: backButton())
            .navigationBarItems(trailing: sortButton())
        }
    }
    func setAlbumName() -> String {
        let year = dataManager.selectedYear!
        let tag = dataManager.selectedTag
        return String("\(tag ?? "") \(year)")
    }
}

extension GalleryView {
    @ViewBuilder
    func backButton() -> some View {
        Button {
            PageManger.shared.pageState = .album
        } label: {
            Image(systemName: Images.chevronLeft)
                .foregroundColor(Color.joyBlue)
        }
    }
    @ViewBuilder
    func sortButton() -> some View {
        Menu {
            Button {
                isNewest = true
                yearlyMemories.sort{ $0.date > $1.date }
            } label: {
                HStack {
                    Text(Texts.recentItemFirst)
                    Spacer()
                    if isNewest {
                        Image(systemName: Images.check)
                    }
                }
            }
            Button {
                isNewest = false
                yearlyMemories.sort{ $0.date < $1.date }
            } label: {
                HStack {
                    Text(Texts.oldestItemFirst)
                    Spacer()
                    if !isNewest {
                        Image(systemName: Images.check)
                    }
                }
            }
        } label: {
            Image(systemName: Images.sort)
                .foregroundColor(Color.joyBlue)
        }
    }
    @ViewBuilder
    func galleryMainView() -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 4.5) {
                ForEach(yearlyMemories, id: \.self) { memory in
                    if !memory.isInvalidated {
                        Image(uiImage: UIImage(data: Data(base64Encoded: memory.img)!) ?? UIImage(named: Images.emptyMemory)!)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: imageSize, height: imageSize)
                            .clipped()
                            .cornerRadius(10)
                            .onTapGesture {
                                dataManager.selectedId = memory.id
                                PageManger.shared.pageState = .carousel
                            }
                    }
                }
            }
        }
    }
}

//struct GalleryView_Previews: PreviewProvider {
//    static var previews: some View {
//        GalleryView()
//    }
//}
