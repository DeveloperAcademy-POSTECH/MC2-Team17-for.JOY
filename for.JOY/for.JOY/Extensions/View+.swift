//
//  View+.swift
//  for.JOY
//
//  Created by hyebin on 2023/09/24.
//

import SwiftUI

extension View {
    func navigationBarColor(_ backgroundColor: UIColor?) -> some View {
       self.modifier(NavigationBarColorModifier(backgroundColor: backgroundColor))
   }

    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = CGSize(width: 350, height: 466)
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
