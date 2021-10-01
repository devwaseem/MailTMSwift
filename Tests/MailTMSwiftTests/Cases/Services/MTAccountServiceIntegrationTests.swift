//
//  MTAccountServiceIntegrationTests.swift
//  
//
//  Created by Waseem Akram on 15/09/21.
//

import Foundation
import XCTest
@testable import MailTMSwift

class MTAccountServiceIntegrationTests: XCTestCase {

    var mockTask: MockDataTask!
    var mockApi: MockAPIService!
    var sut: MTAccountService!

    override func setUp() {
        mockTask = MockDataTask()
        mockApi = MockAPIService(task: mockTask)
        sut = MTAccountService(apiService: mockApi)
    }

    override func tearDown() {
        mockApi = nil
        sut = nil
    }

    // MARK: - Given

    func getAccount(id: String = UUID().uuidString, username: String) -> MTAccount {
        MTAccount(id: id, address: username, quotaLimit: 0, quotaUsed: 0, isDisabled: false, isDeleted: false, createdAt: .init(), updatedAt: .init())
    }

    // MARK: - login tests

    func test_login_whenSuccess_returnsTokenString() throws {
        typealias ResultType = Result<String, MTError>
        typealias APIResultType = Result<MTToken, MTError>

        // given
        let givenfakeToken = "abcdefghijk"
        let givenAuth = MTAuth(address: "something@something.com", password: "1234")
        let givenResult: APIResultType = .success(.init(id: "123", token: givenfakeToken))

        mockApi.givenResult(result: givenResult)

        // when
        let resultExpectation = expectation(description: "Did not return the result")
        var returnedResultOptional: ResultType?
        sut.login(using: givenAuth) { (result: ResultType) in
            returnedResultOptional = result
            resultExpectation.fulfill()
        }

        // then
        XCTAssertEqual(mockApi.endpoint, Endpoints.token)
        XCTAssertEqual(mockApi.headers, [:])
        XCTAssertNil(mockApi.requestAuthToken)
        XCTAssertEqual(mockApi.requestCallCount, 1)
        XCTAssertEqual(mockTask.cancelCallCount, 0)

        let requestBody = try XCTUnwrap(mockApi.requestBody as? MTAuth)
        XCTAssertEqual(requestBody, givenAuth)

        waitForExpectations(timeout: 1)
        XCTAssertNotNil(returnedResultOptional)
        let returnedResult = try XCTUnwrap(returnedResultOptional)
        switch returnedResult {
        case .success(let result):
            XCTAssertEqual(givenfakeToken, result)
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }

    }

    func test_login_whenFailure_returnsError() throws {
        typealias ResultType = Result<String, MTError>
        typealias APIResultType = Result<MTToken, MTError>

        // given
        let givenAuth = MTAuth(address: "something@something.com", password: "1234")
        let givenErrorMessage = "Test Error"
        let givenResult: APIResultType = .failure(.mtError(givenErrorMessage))

        mockApi.givenResult(result: givenResult)

        // when
        let resultExpectation = expectation(description: "Did not return the result")
        var returnedResultOptional: ResultType?
        sut.login(using: givenAuth) { (result: ResultType) in
            returnedResultOptional = result
            resultExpectation.fulfill()
        }

        // then
        XCTAssertEqual(mockApi.endpoint, Endpoints.token)
        XCTAssertNil(mockApi.requestAuthToken)
        XCTAssertEqual(mockApi.headers, [:])
        XCTAssertEqual(mockApi.requestCallCount, 1)
        XCTAssertEqual(mockTask.cancelCallCount, 0)

        let requestBody = try XCTUnwrap(mockApi.requestBody as? MTAuth)
        XCTAssertEqual(requestBody, givenAuth)

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

    // MARK: - createAccount tests

    func test_createAccount_whenSuccess_returnsMTAccount() throws {
        typealias ResultType = Result<MTAccount, MTError>

        // given
        let givenUsername = "example@example.com"
        let givenAuth = MTAuth(address: givenUsername, password: "1234")
        let givenResult: ResultType = .success(.init(id: "123",
                                                     address: givenUsername,
                                                     quotaLimit: 100,
                                                     quotaUsed: 10,
                                                     isDisabled: false,
                                                     isDeleted: false,
                                                     createdAt: .init(),
                                                     updatedAt: .init()))

        mockApi.givenResult(result: givenResult)

        // when
        let resultExpectation = expectation(description: "Did not return the result")
        var returnedResultOptional: ResultType?

        sut.createAccount(using: givenAuth) { (result: ResultType) in
            returnedResultOptional = result
            resultExpectation.fulfill()
        }

        // then
        XCTAssertEqual(mockApi.endpoint, Endpoints.account)
        XCTAssertNil(mockApi.requestAuthToken)
        XCTAssertEqual(mockApi.headers, [:])
        XCTAssertEqual(mockApi.requestCallCount, 1)
        XCTAssertEqual(mockApi.requestMethod, .post)
        XCTAssertEqual(mockTask.cancelCallCount, 0)

        let requestBody = try XCTUnwrap(mockApi.requestBody as? MTAuth)
        XCTAssertEqual(requestBody, givenAuth)

        waitForExpectations(timeout: 1)
        XCTAssertNotNil(returnedResultOptional)
        let returnedResult = try XCTUnwrap(returnedResultOptional)
        switch returnedResult {
        case .success(let result):
            XCTAssertEqual(result.id, "123")
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }

    func test_createAccount_whenFailure_returnsError() throws {
        typealias ResultType = Result<MTAccount, MTError>

        // given
        let givenAuth = MTAuth(address: "something@something.com", password: "1234")
        let givenErrorMessage = "Test Error"
        let givenResult: ResultType = .failure(.mtError(givenErrorMessage))

        mockApi.givenResult(result: givenResult)

        // when
        let resultExpectation = expectation(description: "Did not return the result")
        var returnedResultOptional: ResultType?
        sut.createAccount(using: givenAuth) { (result: ResultType) in
            returnedResultOptional = result
            resultExpectation.fulfill()
        }

        // then
        XCTAssertEqual(mockApi.endpoint, Endpoints.account)
        XCTAssertNil(mockApi.requestAuthToken)
        XCTAssertEqual(mockApi.headers, [:])
        XCTAssertEqual(mockApi.requestCallCount, 1)
        XCTAssertEqual(mockApi.requestMethod, .post)
        XCTAssertEqual(mockTask.cancelCallCount, 0)

        let requestBody = try XCTUnwrap(mockApi.requestBody as? MTAuth)
        XCTAssertEqual(requestBody, givenAuth)

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

    // MARK: - getMyAccount tests

    func test_getMyAccount_whenSuccess_returnsMTAccount() throws {
        typealias ResultType = Result<MTAccount, MTError>

        // given
        let givenfakeToken = "abcdefghijk"
        let givenResult: ResultType = .success(.init(id: "123",
                                                     address: "example@example.com",
                                                     quotaLimit: 100,
                                                     quotaUsed: 10,
                                                     isDisabled: false,
                                                     isDeleted: false,
                                                     createdAt: .init(),
                                                     updatedAt: .init()))

        mockApi.givenResult(result: givenResult)

        // when
        let resultExpectation = expectation(description: "Did not return the result")
        var returnedResultOptional: ResultType?

        sut.getMyAccount(token: givenfakeToken) { (result: ResultType) in
            returnedResultOptional = result
            resultExpectation.fulfill()
        }

        // then
        XCTAssertEqual(mockApi.endpoint, Endpoints.myAccount)
        XCTAssertEqual(mockApi.getAuthToken, givenfakeToken)
        XCTAssertEqual(mockApi.headers, [:])
        XCTAssertEqual(mockApi.getCallCount, 1)
        XCTAssertEqual(mockTask.cancelCallCount, 0)
        waitForExpectations(timeout: 1)
        XCTAssertNotNil(returnedResultOptional)
        let returnedResult = try XCTUnwrap(returnedResultOptional)
        switch returnedResult {
        case .success(let result):
            XCTAssertEqual(result.id, "123")
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }

    func test_getMyAccount_whenFailutre_returnsError() throws {
        typealias ResultType = Result<MTAccount, MTError>

        // given
        let givenfakeToken = "abcdefghijk"
        let givenErrorMessage = "Test Error"
        let givenResult: ResultType = .failure(.mtError(givenErrorMessage))

        mockApi.givenResult(result: givenResult)

        // when
        let resultExpectation = expectation(description: "Did not return the result")
        var returnedResultOptional: ResultType?

        sut.getMyAccount(token: givenfakeToken) { (result: ResultType) in
            returnedResultOptional = result
            resultExpectation.fulfill()
        }

        // then
        XCTAssertEqual(mockApi.endpoint, Endpoints.myAccount)
        XCTAssertEqual(mockApi.getAuthToken, givenfakeToken)
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

    // MARK: - deleteAccount tests

    func test_deleteAccount_whenSuccess_returnsMTAccount() throws {
        typealias ResultType = Result<EmptyResult, MTError>

        // given
        let givenfakeToken = "abcdefghijk"
        let givenResult: ResultType = .success(EmptyResult())

        mockApi.givenResult(result: givenResult)

        // when
        let resultExpectation = expectation(description: "Did not return the result")
        var returnedResultOptional: ResultType?

        sut.deleteAccount(id: "123", token: givenfakeToken) { (result: ResultType) in
            returnedResultOptional = result
            resultExpectation.fulfill()
        }

        // then
        XCTAssertEqual(mockApi.endpoint, Endpoints.accountFromId("123"))
        XCTAssertEqual(mockApi.requestAuthToken, givenfakeToken)
        XCTAssertEqual(mockApi.headers, [:])
        XCTAssertEqual(mockApi.requestCallCount, 1)
        XCTAssertEqual(mockApi.requestMethod, .delete)
        XCTAssertEqual(mockTask.cancelCallCount, 0)
        waitForExpectations(timeout: 1)
        XCTAssertNotNil(returnedResultOptional)
        let returnedResult = try XCTUnwrap(returnedResultOptional)
        switch returnedResult {
            case .success(_):
                // pass
                break
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }

    func test_deleteAccount_whenFailutre_returnsError() throws {
        typealias ResultType = Result<EmptyResult, MTError>

        // given
        let givenfakeToken = "abcdefghijk"
        let givenErrorMessage = "Test Error"
        let givenResult: ResultType = .failure(.mtError(givenErrorMessage))

        mockApi.givenResult(result: givenResult)

        // when
        let resultExpectation = expectation(description: "Did not return the result")
        var returnedResultOptional: ResultType?

        sut.deleteAccount(id: "123", token: givenfakeToken) { (result: ResultType) in
            returnedResultOptional = result
            resultExpectation.fulfill()
        }

        // then
        XCTAssertEqual(mockApi.endpoint, Endpoints.accountFromId("123"))
        XCTAssertEqual(mockApi.requestAuthToken, givenfakeToken)
        XCTAssertEqual(mockApi.headers, [:])
        XCTAssertEqual(mockApi.requestCallCount, 1)
        XCTAssertEqual(mockApi.requestMethod, .delete)
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
