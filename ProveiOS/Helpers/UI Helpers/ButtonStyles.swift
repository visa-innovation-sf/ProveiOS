//
//  ButtonStyles.swift
//  ProveiOS
//
//  Created by Jayakumar Lalithambika, Vivek on 29/11/2021.
//

import SwiftUI

struct OutlineButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(
                isEnabled ? Color(ColorNames.buttonColor.rawValue)
                    : Color(ColorNames.buttonColor.rawValue).opacity(0.5)
            )
            .padding(8)
            .background(
                RoundedRectangle(
                    cornerRadius: 4,
                    style: .continuous
                ).stroke(
                    isEnabled ? Color(ColorNames.buttonColor.rawValue)
                        : Color(ColorNames.buttonColor.rawValue).opacity(0.5)
                )
            ).scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}
