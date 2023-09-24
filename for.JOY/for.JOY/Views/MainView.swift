//
//  MainView.swift
//  for.JOY
//
//  Created by hyebin on 2023/09/23.
//

import SwiftUI

struct MainView: View {
    @StateObject var pageManger = PageManger.shared
    @StateObject var dataManager = DataManager()

    var body: some View {
        ZStack {
            Color.joyBlack
                .ignoresSafeArea()

            switch pageManger.pageState {
            case .album:
                AlbumView(dataManager: dataManager)
            case .gallery:
                GalleryView()
            case .carousel:
                CarouselView()
            case .voice:
                VoiceView(dataManager: dataManager)
            case .info:
                InfoView(dataManager: dataManager)
            case .addDone:
                AddDoneView()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
