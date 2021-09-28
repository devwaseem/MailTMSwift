//
//  MTDomainServiceIntegrationTests.swift
//  
//
//  Created by Waseem Akram on 15/09/21.
//

import Foundation
import XCTest
@testable import MailTMSwift

class MTDomainServiceIntegrationTests: XCTestCase {

    var mockTask: MockDataTask!
    var mockApi: MockAPIService!
    var sut: MTDomainService!

    override func setUp() {
        super.setUp()
        mockTask = MockDataTask()
        mockApi = MockAPIService(task: mockTask)
        sut = MTDomainService(apiService: mockApi)
    }

    override func tearDown() {
        mockTask = nil
        mockApi = nil
        sut = nil
        super.tearDown()
    }

    func getDomain(id: String = "1") -> MTDomain {
        MTDomain(id: "1", domain: "example.com", isActive: true, isPrivate: false, createdAt: .init(), updatedAt: .init())
    }

    func test_getAllDomains_whenSuccess_returnsDomainsList() throws {
        typealias ReturningDataType = [MTDomain]
        typealias ResultType = Result<ReturningDataType, MTError>
        typealias HydraResultType = Result<HydraWrapper<ReturningDataType>, MTError>

        // given
        let givenDomain = getDomain()

        let givenDomains = [ givenDomain ]
        let givenSuccessResult: HydraResultType = .success(.init(context: "", id: "", type: "", result: givenDomains, hydraTotalItems: 1))

        mockApi.givenResult(result: givenSuccessResult)

        // when
        let resultExpectation = expectation(description: "Did not return the result")
        var returnedResultOptional: ResultType?
        sut.getAllDomains { (result: ResultType) in
            returnedResultOptional = result
            resultExpectation.fulfill()
        }

        // then
        XCTAssertEqual(mockApi.endpoint, Endpoints.domains)
        XCTAssertNil(mockApi.getAuthToken)
        XCTAssertEqual(mockApi.headers, [:])
        XCTAssertEqual(mockApi.getCallCount, 1)
        XCTAssertEqual(mockTask.cancelCallCount, 0)
        waitForExpectations(timeout: 1)
        XCTAssertNotNil(returnedResultOptional)
        let returnedResult = try XCTUnwrap(returnedResultOptional)
        switch returnedResult {
        case .success(let result):
            XCTAssertEqual(result.count, givenDomains.count)
            XCTAssertEqual(result[0].id, givenDomain.id)
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }

    func test_getAllDomains_whenFailure_returnError() throws {
        typealias ReturningDataType = [MTDomain]
        typealias ResultType = Result<ReturningDataType, MTError>
        typealias HydraResultType = Result<HydraWrapper<ReturningDataType>, MTError>

        // given
        let givenErrorMessage = "Test Error"
        let givenErrorResult: HydraResultType = .failure(.mtError(givenErrorMessage))

        mockApi.givenResult(result: givenErrorResult)

        // when
        let resultExpectation = expectation(description: "Did not return the result")
        var returnedResultOptional: ResultType?
        sut.getAllDomains { (result: ResultType) in
            returnedResultOptional = result
            resultExpectation.fulfill()
        }

        // then
        XCTAssertEqual(mockApi.endpoint, Endpoints.domains)
        XCTAssertNil(mockApi.getAuthToken)
        XCTAssertEqual(mockApi.headers, [:])
        XCTAssertEqual(mockApi.getCallCount, 1)
        XCTAssertEqual(mockTask.cancelCallCount, 0)
        waitForExpectations(timeout: 1)
        XCTAssertNotNil(returnedResultOptional)
        let returnedResult = try XCTUnwrap(returnedResultOptional)
        switch returnedResult {
        case .success(_):
            XCTFail("Returned success, Should return failure")
        case .failure(let error):
            if case let .mtError(errorMessage) = error {
                XCTAssertEqual(errorMessage, givenErrorMessage)
            } else {
                XCTFail("Returned error was not the same type")
            }

        }
    }

    func test_getDomain_whenSuccess_returnsDomain() throws {
        typealias ReturningDataType = MTDomain
        typealias ResultType = Result<ReturningDataType, MTError>

        // given
        let givenDomainId = "1234"
        let givenDomain = getDomain(id: givenDomainId)

        let givenSuccessResult: ResultType = .success(givenDomain)

        mockApi.givenResult(result: givenSuccessResult)
        XCTAssertEqual(mockTask.cancelCallCount, 0)
        // when
        let resultExpectation = expectation(description: "Did not return the result")
        var returnedResultOptional: ResultType?
        sut.getDomain(id: givenDomainId) { (result: ResultType) in
            returnedResultOptional = result
            resultExpectation.fulfill()
        }

        // then
        XCTAssertEqual(mockApi.endpoint, Endpoints.domainFromId(givenDomainId))
        XCTAssertNil(mockApi.getAuthToken)
        XCTAssertEqual(mockApi.headers, [:])
        XCTAssertEqual(mockApi.getCallCount, 1)

        waitForExpectations(timeout: 1)
        XCTAssertNotNil(returnedResultOptional)
        let returnedResult = try XCTUnwrap(returnedResultOptional)
        switch returnedResult {
        case .success(let result):
            XCTAssertEqual(result.id, givenDomain.id)
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }

    func test_getDomain_whenFailure_returnsError() throws {
        typealias ReturningDataType = MTDomain
        typealias ResultType = Result<ReturningDataType, MTError>

        // given
        let givenDomainId = "1234"
        let givenErrorMessage = "Test Error"
        let givenErrorResult: ResultType = .failure(.mtError(givenErrorMessage))

        mockApi.givenResult(result: givenErrorResult)

        // when
        let resultExpectation = expectation(description: "Did not return the result")
        var returnedResultOptional: ResultType?
        sut.getDomain(id: givenDomainId) { (result: ResultType) in
            returnedResultOptional = result
            resultExpectation.fulfill()
        }

        // then
        XCTAssertEqual(mockApi.endpoint, Endpoints.domainFromId(givenDomainId))
        XCTAssertNil(mockApi.getAuthToken)
        XCTAssertEqual(mockApi.headers, [:])
        XCTAssertEqual(mockApi.getCallCount, 1)
        XCTAssertEqual(mockTask.cancelCallCount, 0)
        waitForExpectations(timeout: 1)
        XCTAssertNotNil(returnedResultOptional)
        let returnedResult = try XCTUnwrap(returnedResultOptional)
        switch returnedResult {
        case .success(_):
            XCTFail("Returned success, Should return failure")
        case .failure(let error):
            if case let .mtError(errorMessage) = error {
                XCTAssertEqual(errorMessage, givenErrorMessage)
            } else {
                XCTFail("Returned error was not the same type")
            }
        }
    }

}
