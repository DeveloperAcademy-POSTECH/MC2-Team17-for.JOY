//
//  PageManager.swift
//  for.JOY
//
//  Created by hyebin on 2023/09/23.
//

import Foundation

enum PageState {
    case album
    case voice
    case info
    case gallery
    case carousel
}

class PageManger: ObservableObject {
    static let shared = PageManger()
    private init() {}

    @Published var pageState: PageState = .album
}
