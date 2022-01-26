//
//  ProveEndpoints.swift
//  ProveiOS
//
//  Created by Jayakumar Lalithambika, Vivek on 12/01/2022.
//

import Foundation


struct ProveIPCheckEndpoint: EndpointType {
    var payload: HTTPParameters? = nil
    var method: HTTPMethod = .get
    var path: String = "https://device.payfone.com:4443/whatismyipaddress"
    var headers: HTTPHeaders? = nil

    func buildRequest(_ environment: ServerEnvironment) -> URLRequest {
        guard let url = URL(string: path) else {
                   preconditionFailure("Invalid URL")
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.timeoutInterval = 15

        return urlRequest
    }
}
