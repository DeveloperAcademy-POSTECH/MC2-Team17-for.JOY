//
//  BarView.swift
//  for.JOY
//
//  Created by hyebin on 2023/09/24.
//

import SwiftUI

struct BarView: View {
    var value: CGFloat
    var index: Int

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient:
                            Gradient(colors: gradientColor(index)),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 2, height: value)
        }
    }

    func gradientColor(_ indexValue: Int) -> [Color] {
        if indexValue%2 == 0 {
            return [Color.joyBlue, Color.joyYellow]
        } else {
            return [Color.joyYellow, Color.joyBlue]
        }
    }
}
