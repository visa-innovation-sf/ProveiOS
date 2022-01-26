//
//  Endpoint.swift
//  ProveiOS
//
//  Created by Jayakumar Lalithambika, Vivek on 23/11/2021.
//

import Foundation

protocol EndpointType {
    var method: HTTPMethod { get }

    var headers: HTTPHeaders? { get set }

    var payload: HTTPParameters? { get set }

    var path: String { get }

    func buildRequest(_ environment: ServerEnvironment) -> URLRequest
}

extension EndpointType {
    var headers: HTTPHeaders? {
        return HTTPHeaders.defaultHeaders
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

typealias HTTPParameters = [String: Any]

typealias HTTPHeaders = [String: String]

extension HTTPHeaders {
    /// The default headers for JSON payload
    static let defaultHeaders = [
        "Content-Type": "application/json"
    ]
}

extension HTTPParameters {
    /// The default headers for JSON payload
    static let defaultBody = [
        "ApiClientId": "VSA44u6j8k6yI03zDSTG",
        "SubClientId": "MPS2zC31h4b4j0kDHSTG",
    ]
}

extension URL {
    func getQueryParameter(param: String) -> String? {
        guard let url = URLComponents(string: absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
}
