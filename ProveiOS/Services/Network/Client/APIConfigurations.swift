//
//  APIConfigurations.swift
//  ProveiOS
//
//  Created by Jayakumar Lalithambika, Vivek on 23/11/2021.
//

import Foundation

struct BaseURL {
    static func proveBaseURL(environment: ServerEnvironment) -> String {
        switch environment {
        case .staging:
            return "www.staging-prove.com"
        case .production:
            return "www.prod-prove.com"
        }
    }

    static func visaBaseURL(environment: ServerEnvironment) -> String {
        switch environment {
        case .staging:
            return "vtsmap.digital.visa.com"
        case .production:
            return "vtsmap.digital.visa.com"
        }
    }
}

enum ServerEnvironment: String, CaseIterable, Identifiable {
    case staging = "Staging"
    case production = "Production"
    var id: String { rawValue }
}
