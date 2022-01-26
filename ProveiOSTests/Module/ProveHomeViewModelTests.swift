//
//  ProveHomeViewModelTests.swift
//  ProveiOSTests
//
//  Created by Jayakumar Lalithambika, Vivek on 06/12/2021.
//

import Combine
import XCTest
@testable import ProveiOS

class ProveHomeViewModelTests: XCTestCase {
    var sut: ProveHomeViewModel?
    private var cancellables: Set<AnyCancellable>!
    var mockApiClient = MockAPIClient(configuration: .ephemeral, environment: .staging)

    override func setUp() {}

    override func tearDown() {
        sut = nil
        Resolver.root = Resolver.main
    }

    func testPingServerCall() throws {
        mockApiClient.isSuccess = true
        sut = ProveHomeViewModel(
            apiClient: mockApiClient,
            ipProvider: IPAddressProvider()
        )
        sut?.pingServer()
        let expectation = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNotNil(self.sut?.serverResponse)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func testAuthByRedirect() throws {
        mockApiClient.isSuccess = true
        mockApiClient.modelItem = AuthenticateResponse(
            requestID: "ABCD-123-456",
            details: "Successful Response",
            additionalInfo: "Additional info",
            status: 0,
            response: AuthenticateResponseDetails(
                authenticateTransactionID: "12345",
                redirectTargetURL: "http://www.google.com"
            )
        )

        sut = ProveHomeViewModel(
            apiClient: mockApiClient,
            ipProvider: IPAddressProvider()
        )
        sut?.ipAddress = "123433553"

        sut?.authenticateByRedirect()
        let expectation = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertNotNil(self.sut?.serverResponse)
            XCTAssertEqual(self.sut?.redirectTargetURL, "http://www.google.com")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
}
