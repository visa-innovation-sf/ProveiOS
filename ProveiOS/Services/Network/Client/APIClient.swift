//
//  APIClient.swift
//  ProveiOS
//
//  Created by Jayakumar Lalithambika, Vivek on 23/11/2021.
//

import Combine
import Foundation

protocol APIClientType {
    init(
        configuration: URLSessionConfiguration,
        environment: ServerEnvironment
    )
    func change(environment: ServerEnvironment)
    func getURLResponse(endpoint: EndpointType) -> AnyPublisher<HTTPURLResponse, APIError>
    func getData(endpoint: EndpointType) -> AnyPublisher<Data, APIError>
    func request<T: Decodable>(
        type: T.Type,
        endpoint: EndpointType
    ) -> AnyPublisher<T, APIError>
}

final class APIClient: NSObject, APIClientType {
    private let sessionConfiguration: URLSessionConfiguration
    private(set) var environment: ServerEnvironment
    private lazy var urlSession = URLSession(
        configuration: sessionConfiguration,
        delegate: self,
        delegateQueue: nil
    )

    required init(
        configuration: URLSessionConfiguration = URLSessionConfiguration.default,
        environment: ServerEnvironment = .staging
    ) {
        self.sessionConfiguration = configuration
        self.environment = environment
    }

    func change(environment: ServerEnvironment) {
        self.environment = environment
    }

    func request<T: Decodable>(
        type: T.Type,
        endpoint: EndpointType
    ) -> AnyPublisher<T, APIError> {
        return getData(endpoint: endpoint)
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { APIError(from: $0) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func getURLResponse(endpoint: EndpointType) -> AnyPublisher<HTTPURLResponse, APIError> {
        let urlRequest = endpoint.buildRequest(environment)
        print("URL:\n \(urlRequest.url?.absoluteString ?? "")")
        return urlSession.dataTaskPublisher(for: endpoint.buildRequest(environment))
            .tryMap { try self.validateResponse(result: $0) }
            .mapError { APIError(from: $0) }
            .eraseToAnyPublisher()
    }

    func getData(endpoint: EndpointType) -> AnyPublisher<Data, APIError> {
        let urlRequest = endpoint.buildRequest(environment)

        print("URL Request Header:\n \(urlRequest.allHTTPHeaderFields ?? [:])")
        print(
            "URL Request Body:\n \(String(data: urlRequest.httpBody ?? Data(), encoding: .utf8) ?? "no data")"
        )
        print("URL:\n \(urlRequest.url?.absoluteString ?? "")")

        return urlSession.dataTaskPublisher(for: urlRequest)
            .tryMap { try self.validate(result: $0) }
            .mapError { APIError(from: $0) }
            .eraseToAnyPublisher()
    }
}

extension APIClient {
    func validateResponse(result: URLSession.DataTaskPublisher.Output) throws -> HTTPURLResponse {
        guard let httpResponse = result.response as? HTTPURLResponse else {
            throw APIError.noResponse
        }
        #if DEBUG
        print("""
        API Response:\n
        \(httpResponse)
        """)
        #endif
        return httpResponse
    }

    func validate(result: URLSession.DataTaskPublisher.Output) throws -> Data {
        guard let httpResponse = result.response as? HTTPURLResponse else {
            throw APIError.noResponse
        }

        #if DEBUG
        print("""
        API Response:\n
        \(String(data: result.data, encoding: .utf8) ?? "no data")\n
        """)
        #endif

        let statusCode = httpResponse.statusCode
        guard (200 ..< 400).contains(statusCode) else {
            let backendError = APIError.failedRequest(statusCode: statusCode)
            throw backendError
        }

        return result.data
    }
}

extension APIClient: URLSessionDelegate {
    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard let trust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        let urlCredential = URLCredential(trust: trust)
        completionHandler(.useCredential, urlCredential)
    }
}
