//
//  AlbumView.swift
//  for.JOY
//
//  Created by hyebin on 2023/09/23.
//

import SwiftUI

struct AlbumView: View {
    @ObservedObject var dataManager: DataManager
    @StateObject var realmManager = RealmManager.shared
    @State var selectedTag = Texts.allTags
    @State var isAllSelected = true
    @State var isNewest = true
    private let emptypMemoryImgSize = 200.0 * UIScreen.height / 844
    var columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 20), count: 2)
    private let imageSize = UIScreen.width / 2 - 52
    var body: some View {
        NavigationView {
            ZStack {
                Color.joyBlack
                    .ignoresSafeArea()
                albumMainView()
                VStack {
                    Spacer()
                    PhotoSelectButton(dataManager: dataManager)
                }
            }
            .edgesIgnoringSafeArea([.bottom])
            .navigationBarItems(leading: tagButton())
            .navigationBarItems(trailing: sortButton())
        }
    }
}

extension AlbumView {
    @ViewBuilder
    func tagButton() -> some View {
        Menu {
            Button {
                selectedTag = Texts.allTags
                isAllSelected = true
                realmManager.selectYealryMemories()
            } label: {
                HStack {
                    Text(Texts.allTags)
                    Spacer()
                    if isAllSelected {
                        Image(systemName: Images.check)
                    }
                }
            }
            ForEach(realmManager.distinctTags, id: \.self) { tag in
                Button {
                    selectedTag = tag
                    isAllSelected = false
                    realmManager.selectYealryMemories(selectedTag)
                } label: {
                    HStack {
                        Text(tag)
                        Spacer()
                        if tag == selectedTag {
                            Image(systemName: Images.check)
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: Images.tag)
                Text(selectedTag)
                    .lineLimit(1)
            }
            .font(Font.body2Kor)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(Color.joyBlue)
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .foregroundColor(.joyWhite)
        .transaction { transaction in
            transaction.animation = nil
        }
    }
    @ViewBuilder
    func sortButton() -> some View {
        Menu {
            Button {
                isNewest = true
                realmManager.getDistinctYears()
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
                realmManager.getDistinctYears(isNewest)
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
                .padding(.leading, 60)
        }
    }
    @ViewBuilder
    func albumMainView() -> some View {
        if realmManager.memories.isEmpty {
            emptyMemoryView()
        } else {
            memoryGridView()
        }
    }
    @ViewBuilder
    func emptyMemoryView() -> some View {
        VStack(spacing: 25) {
            Image(Images.emptyMemory)
                .resizable()
                .frame(width: emptypMemoryImgSize, height: emptypMemoryImgSize)
            Text(Texts.emptyMemoryDescription)
                .font(Font.body2Kor)
                .foregroundColor(Color.joyWhite)
        }
    }
    @ViewBuilder
    func memoryGridView() -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(realmManager.distinctYears, id: \.self) { year in
                    if let yearlyMemories = realmManager.yearlyMemories[year] {
                        ZStack {
                            Color.joyWhite
                            VStack(alignment: .trailing, spacing: 0) {
                                Image(Images.emptyMemory)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: imageSize, height: imageSize)
                                    .clipped()
                                    .cornerRadius(9)
                                    .padding(.top, 13)
                                Text("\(year)"
                                    .replacingOccurrences(of: ",", with: ""))
                                .font(Font.title1)
                                .foregroundColor(Color.joyBlack)
                                .padding(10)
                            }
                            .padding(.horizontal, 13)
                        }
                        .onTapGesture {
                            PageManger.shared.pageState = .gallery
                        }
                        .cornerRadius(10)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }
}

struct AlbumView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumView(dataManager: DataManager())
    }
}
