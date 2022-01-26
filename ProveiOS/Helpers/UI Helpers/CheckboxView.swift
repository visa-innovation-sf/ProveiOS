//
//  CheckboxView.swift
//  ProveiOS
//
//  Created by Jayakumar Lalithambika, Vivek on 29/11/2021.
//

import SwiftUI

struct CheckboxStyle: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        return HStack {
            configuration.label
            Spacer()
            Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(.gray)
                .font(.system(size: 20, weight: .regular, design: .default))
                .padding(2)
        }
        .onTapGesture { configuration.isOn.toggle() }
    }
}
