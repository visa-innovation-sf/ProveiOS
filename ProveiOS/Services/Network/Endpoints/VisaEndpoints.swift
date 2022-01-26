//
//  VisaEndpoints.swift
//  ProveiOS
//
//  Created by Jayakumar Lalithambika, Vivek on 24/11/2021.
//

import Foundation

// https://vtsmap.digital.visa.com/VTSMAP/authenticateByRedirect
struct AuthByRedirectEndpoint: EndpointType {
    var payload: HTTPParameters? = HTTPParameters.defaultBody
    var method: HTTPMethod = .post
    var path: String = "VTSMAP/authenticateByRedirect"
    var headers: HTTPHeaders? = HTTPHeaders.defaultHeaders

    func buildRequest(_ environment: ServerEnvironment) -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = BaseURL.visaBaseURL(environment: environment)
        components.path = "/" + path
        components.queryItems = nil

        guard let url = components.url else {
            preconditionFailure("Invalid URL")
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.timeoutInterval = 30

        headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        if let bodyPayload = payload {
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: bodyPayload)
        }

        return urlRequest
    }
}
// https://vtsmap.digital.visa.com/VTSMAP/authenticateByRedirectFinish
struct AuthByRedirectFinishEndpoint: EndpointType {
    var payload: HTTPParameters? = HTTPParameters.defaultBody
    var method: HTTPMethod = .post
    var path: String = "VTSMAP/authenticateByRedirectFinish"
    var headers: HTTPHeaders? = HTTPHeaders.defaultHeaders

    func buildRequest(_ environment: ServerEnvironment) -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = BaseURL.visaBaseURL(environment: environment)
        components.path = "/" + path
        components.queryItems = nil

        guard let url = components.url else {
            preconditionFailure("Invalid URL")
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.timeoutInterval = 30

        headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        if let bodyPayload = payload {
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: bodyPayload)
        }

        return urlRequest
    }
}
// https://vtsmap.digital.visa.com/VTSMAP/Test

struct VTSMAPPingCheckEndpoint: EndpointType {
    var payload: HTTPParameters? = nil
    var method: HTTPMethod = .get
    var path: String = "VTSMAP/Test"
    var headers: HTTPHeaders? = HTTPHeaders.defaultHeaders

    func buildRequest(_ environment: ServerEnvironment) -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = BaseURL.visaBaseURL(environment: environment)
        components.path = "/" + path
        components.queryItems = nil

        guard let url = components.url else {
            preconditionFailure("Invalid URL")
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.timeoutInterval = 15

        headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        return urlRequest
    }
}

struct VFSRedirectEndpoint: EndpointType {
    var payload: HTTPParameters? = nil
    var method: HTTPMethod = .get
    var path: String = ""
    var headers: HTTPHeaders? = nil

    func buildRequest(_ environment: ServerEnvironment) -> URLRequest {
        guard let url = URL(string: path) else {
            preconditionFailure("Invalid URL")
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.timeoutInterval = 60

        return urlRequest
    }
}
