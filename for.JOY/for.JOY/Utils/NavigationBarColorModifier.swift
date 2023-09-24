//
//  NavigationBarColorModifier.swift
//  for.JOY
//
//  Created by hyebin on 2023/09/25.
//

import SwiftUI

struct NavigationBarColorModifier: ViewModifier {
    init(backgroundColor: UIColor?) {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = backgroundColor
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance
    }

    func body(content: Content) -> some View {
        content
    }
}
