//
//  MainView.swift
//  for.JOY
//
//  Created by hyebin on 2023/09/23.
//

import SwiftUI

struct MainView: View {
    @StateObject var pageManger = PageManger.shared

    var body: some View {
        ZStack {
            Color.joyBlack
                .ignoresSafeArea()

            switch pageManger.pageState {
            case .album:
                AlbumView()
            case .gallery:
                GalleryView()
            case .carousel:
                CarouselView()
            case .voice:
                VoiceView()
            case .info:
                InfoView()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
