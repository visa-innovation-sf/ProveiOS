//
//  ProveiOSApp.swift
//  ProveiOS
//
//  Created by Jayakumar Lalithambika, Vivek on 16/11/2021.
//

import SwiftUI

@main struct ProveiOSApp: App {
    var body: some Scene {
        WindowGroup {
            ProveHomeView(viewModel: ProveHomeViewModel())
        }
    }
}

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        register { APIClient(
            configuration: .ephemeral,
            environment: .staging
        ) as APIClientType
        }.scope(.application)

        register { IPAddressProvider() as IPAddressProviderProtocol }
    }
}
