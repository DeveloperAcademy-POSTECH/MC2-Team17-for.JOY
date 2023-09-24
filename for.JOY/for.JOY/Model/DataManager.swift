//
//  DataManager.swift
//  for.JOY
//
//  Created by hyebin on 2023/09/24.
//

import SwiftUI

class DataManager: ObservableObject {
    @Published var imageData: UIImage?
    @Published var recording: URL?
    @Published var info: Info?
}
