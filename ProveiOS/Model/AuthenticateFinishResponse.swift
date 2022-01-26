//
//  RedirectFinishResponse.swift
//  ProveiOS
//
//  Created by Jayakumar Lalithambika, Vivek on 05/12/2021.
//

import Foundation

struct AuthenticateFinishResponse: Codable {
    let redirectResponseDescription, requestID: String
    let additionalInfo: String?
    let response: AuthenticateFinishResponseDetails?
    let status: Int

    enum CodingKeys: String, CodingKey {
        case redirectResponseDescription = "Description"
        case requestID = "RequestId"
        case response = "Response"
        case status = "Status"
        case additionalInfo = "AdditionalInfo"
    }

    var description: String {
        return """
        Description: \(redirectResponseDescription)\n
        RequestId:  \(requestID)\n
        Status: \(status)\n
        Additional Info: \(additionalInfo ?? "None")\n
        \(response?.description ?? "")\n
        """
    }
}

struct AuthenticateFinishResponseDetails: Codable {
    let authenticateFinishTransactionID, payfoneAlias, authenticationCode,
        authenticationExpiration: String?
    let mobileNumber, mobileCountryCode, mobileOperatorName: String?

    enum CodingKeys: String, CodingKey {
        case authenticateFinishTransactionID = "AuthenticateFinishTransactionId"
        case payfoneAlias = "PayfoneAlias"
        case authenticationCode = "AuthenticationCode"
        case authenticationExpiration = "AuthenticationExpiration"
        case mobileNumber = "MobileNumber"
        case mobileCountryCode = "MobileCountryCode"
        case mobileOperatorName = "MobileOperatorName"
    }

    var description: String {
        return """
        AuthenticateFinishTransactionId: \(authenticateFinishTransactionID  ?? "")\n
        PayfoneAlias:  \(payfoneAlias ?? "")\n
        AuthenticationCode: \(authenticationCode  ?? "")\n
        AuthenticationExpiration: \(authenticationExpiration  ?? "")\n
        MobileNumber: \(mobileNumber  ?? "")\n
        MobileCountryCode: \(mobileCountryCode  ?? "")\n
        MobileOperatorName: \(mobileOperatorName  ?? "")\n
        """
    }
}
