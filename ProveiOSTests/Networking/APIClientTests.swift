//
//  APIClientTests.swift
//  ProveiOSTests
//
//  Created by Jayakumar Lalithambika, Vivek on 24/11/2021.
//

import Combine
import XCTest
@testable import ProveiOS

class APIClientTests: XCTestCase {
    let targetURL = VTSMAPPingCheckEndpoint().buildRequest(.staging).url!
    private var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        cancellables = []
    }

    override func tearDownWithError() throws {
        BlockTestProtocolHandler.removeHandlers(byHost: targetURL.host!)
    }

    func testEndpoints() {
        let endpoint = VTSMAPPingCheckEndpoint()
        XCTAssertEqual(
            endpoint.buildRequest(.staging).url?.absoluteString,
            "https://vtsmap.digital.visa.com/VTSMAP/Test"
        )
    }

    func testSuccessfulResponse() {
        let sampleJSON: Data? = "{ \"message\": \"success\"}".data(using: .utf8)

        BlockTestProtocolHandler
            .register(url: targetURL) { (request: URLRequest) -> (
                response: HTTPURLResponse,
                data: Data?
            ) in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: BlockTestProtocolHandler.httpVersion,
                headerFields: nil
            )!
            return (response, sampleJSON)
            }

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [
            BlockTestProtocolHandler.self
        ]

        let apiClient = APIClient(configuration: config, environment: .production)
        apiClient.change(environment: .staging)
        XCTAssert(apiClient.environment == .staging)

        let fetchCompleted = XCTestExpectation(description: "Success Fetch Completed")
        defer {
            self.wait(for: [fetchCompleted], timeout: 7)
        }

        var object: SampleCodable?
        var error: Error?

        apiClient.request(type: SampleCodable.self, endpoint: VTSMAPPingCheckEndpoint())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case let .failure(encounteredError):
                    error = encounteredError
                }
                XCTAssertNil(error)
                XCTAssertEqual(object?.message, "success")
                fetchCompleted.fulfill()
            }, receiveValue: { value in
                object = value
            })
            .store(in: &cancellables)
    }

    func testFailureResponse() {
        BlockTestProtocolHandler
            .register(url: targetURL) { (request: URLRequest) -> (
                response: HTTPURLResponse,
                data: Data?
            ) in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 404,
                httpVersion: BlockTestProtocolHandler.httpVersion,
                headerFields: nil
            )!
            return (response, nil)
            }

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [
            BlockTestProtocolHandler.self
        ]

        let apiClient = APIClient(configuration: config, environment: .staging)

        let fetchFailed = XCTestExpectation(description: "Failure Fetch Completed")
        defer {
            self.wait(for: [fetchFailed], timeout: 7)
        }

        var object: SampleCodable?
        var error: Error?

        apiClient.request(type: SampleCodable.self, endpoint: VTSMAPPingCheckEndpoint())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case let .failure(encounteredError):
                    error = encounteredError
                }
                XCTAssertNotNil(error)
                if let apiError = error as? APIError {
                    XCTAssertEqual(apiError, APIError.failedRequest(statusCode: 404))
                }
                XCTAssertNil(object)
                fetchFailed.fulfill()
            }, receiveValue: { value in
                object = value
            })
            .store(in: &cancellables)
    }

    func testJSONParsingFailure() {
        let sampleJSON: Data? = "{ \"fakemessage\": \"success\"}".data(using: .utf8)

        BlockTestProtocolHandler
            .register(url: targetURL) { (request: URLRequest) -> (
                response: HTTPURLResponse,
                data: Data?
            ) in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: BlockTestProtocolHandler.httpVersion,
                headerFields: nil
            )!
            return (response, sampleJSON)
            }

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [
            BlockTestProtocolHandler.self
        ]

        let apiClient = APIClient(configuration: config, environment: .staging)

        let fetchFailed = XCTestExpectation(description: "Failure Fetch Completed")
        defer {
            self.wait(for: [fetchFailed], timeout: 7)
        }

        var object: SampleCodable?
        var error: Error?

        apiClient.request(type: SampleCodable.self, endpoint: VTSMAPPingCheckEndpoint())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case let .failure(encounteredError):
                    error = encounteredError
                }
                XCTAssertNotNil(error)

                if let apiError = error as? APIError,
                   case APIError.invalidResponse = apiError
                {
                    // success
                } else {
                    XCTFail("Invalid response was expected")
                }

                XCTAssertNil(object)
                fetchFailed.fulfill()
            }, receiveValue: { value in
                object = value
            })
            .store(in: &cancellables)
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
}
