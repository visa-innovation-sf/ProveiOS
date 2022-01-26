//
//  MockAPIClient.swift
//  ProveiOSTests
//
//  Created by Jayakumar Lalithambika, Vivek on 06/12/2021.
//

import Combine
import Foundation
@testable import ProveiOS

struct MockAPIClient: APIClientType {
    init(configuration: URLSessionConfiguration, environment: ServerEnvironment) {}

    func change(environment: ServerEnvironment) {}

    var isSuccess = true

    var modelItem: Codable?

    func getData(endpoint: EndpointType) -> AnyPublisher<Data, APIError> {
        if isSuccess {
            let data = "Success".data(using: .utf8)!
            return Just(data)
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: APIError.failedRequest(statusCode: 404))
                .eraseToAnyPublisher()
        }
    }

    func request<T: Decodable>(type: T.Type, endpoint: EndpointType)
        -> AnyPublisher<T, APIError>
    {
        print("Request called")
        if let data = modelItem {
            return Just(data as! T)
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: APIError.invalidResponse(errorMessage: "Mock Error"))
                .eraseToAnyPublisher()
        }
    }
}
