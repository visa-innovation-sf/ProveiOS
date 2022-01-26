//
//  ProveiOSTests.swift
//  ProveiOSTests
//
//  Created by Jayakumar Lalithambika, Vivek on 16/11/2021.
//

import Combine
import XCTest

@testable import ProveiOS

class ProveiOSTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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

extension XCTestCase {
    typealias CompetionResult = (
        expectation: XCTestExpectation,
        cancellable: AnyCancellable
    )
    func expectCompletion<T: Publisher>(
        of publisher: T,
        timeout: TimeInterval = 2,
        file: StaticString = #file,
        line: UInt = #line
    ) -> CompetionResult {
        let exp =
            expectation(description: "Successful completion of " + String(describing: publisher))
        let cancellable = publisher
            .sink(receiveCompletion: { completion in
                if case .finished = completion {
                    exp.fulfill()
                }
            }, receiveValue: { _ in })
        return (exp, cancellable)
    }

    func expectValue<T: Publisher>(
        of publisher: T,
        timeout: TimeInterval = 2,
        file: StaticString = #file,
        line: UInt = #line,
        equals: [T.Output]
    ) -> CompetionResult where T.Output: Equatable {
        let exp = expectation(description: "Correct values of " + String(describing: publisher))
        var mutableEquals = equals
        let cancellable = publisher
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { value in
                    if value == mutableEquals.first {
                        mutableEquals.remove(at: 0)
                        if mutableEquals.isEmpty {
                            exp.fulfill()
                        }
                    }
                }
            )
        return (exp, cancellable)
    }
}
