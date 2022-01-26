//
//  ViewExtensions.swift
//  ProveiOS
//
//  Created by Jayakumar Lalithambika, Vivek on 29/11/2021.
//

import SwiftUI
import UIKit

struct NavigationBarColor: ViewModifier {
    init(backgroundColor: UIColor, tintColor: UIColor) {
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.backgroundColor = backgroundColor
        coloredAppearance.titleTextAttributes = [.foregroundColor: tintColor]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: tintColor]

        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().tintColor = tintColor
    }

    func body(content: Content) -> some View {
        content
    }
}

extension View {
    func navigationBarColor(backgroundColor: UIColor, tintColor: UIColor) -> some View {
        modifier(NavigationBarColor(backgroundColor: backgroundColor, tintColor: tintColor))
    }
}

struct DismissingKeyboard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                let keyWindow = UIApplication.shared.connectedScenes
                        .filter({$0.activationState == .foregroundActive})
                        .map({$0 as? UIWindowScene})
                        .compactMap({$0})
                        .first?.windows
                        .filter({$0.isKeyWindow}).first
                keyWindow?.endEditing(true)
        }
    }
}
