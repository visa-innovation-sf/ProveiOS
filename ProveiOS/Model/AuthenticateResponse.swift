//
//  RedirectResponse.swift
//  ProveiOS
//
//  Created by Jayakumar Lalithambika, Vivek on 05/12/2021.
//

import Foundation

// MARK: - RedirectResponse

struct AuthenticateResponse: Codable {
    let requestID, details: String
    let additionalInfo: String?
    let status: Int

    let response: AuthenticateResponseDetails?

    enum CodingKeys: String, CodingKey {
        case requestID = "RequestId"
        case details = "Description"
        case response = "Response"
        case status = "Status"
        case additionalInfo = "AdditionalInfo"
    }

    var description: String {
        return """
        RequestId: \(requestID)\n
        Description:  \(details)\n
        Status: \(status)\n
        Additional Info: \(additionalInfo ?? "None")\n
        \(response?.description ?? "")\n
        """
    }
}

struct AuthenticateResponseDetails: Codable {
    let authenticateTransactionID: String
    let redirectTargetURL: String

    enum CodingKeys: String, CodingKey {
        case authenticateTransactionID = "AuthenticateTransactionId"
        case redirectTargetURL = "RedirectTargetUrl"
    }

    var description: String {
        return """
        AuthenticateTransactionId: \(authenticateTransactionID)\n
        RedirectTargetUrl: \(redirectTargetURL)\n
        """
    }
}
