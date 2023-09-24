//
//  UIImage+.swift
//  for.JOY
//
//  Created by Nayeon Kim on 2023/09/25.
//

import SwiftUI

extension UIImage {
    func toPngString() -> String? {
        let data = self.pngData()
        return data?.base64EncodedString(options: .endLineWithLineFeed)
    }
}
