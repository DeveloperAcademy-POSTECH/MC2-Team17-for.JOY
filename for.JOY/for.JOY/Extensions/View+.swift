//
//  View+.swift
//  for.JOY
//
//  Created by hyebin on 2023/09/24.
//

import SwiftUI

extension View {
    func keyboardAdaptive() -> some View {
        ModifiedContent(content: self, modifier: KeyboardAdaptiveModifier())
    }
}
