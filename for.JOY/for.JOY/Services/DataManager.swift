//
//  DataManager.swift
//  for.JOY
//
//  Created by hyebin on 2023/09/24.
//

import SwiftUI
import RealmSwift

class DataManager: ObservableObject {
    @Published var imageData: UIImage?
    @Published var recording: URL?
    @Published var info: Info?
    @Published var selectedYear: Int?
    @Published var selectedTag: String?
    @Published var selectedId: ObjectId?
}
