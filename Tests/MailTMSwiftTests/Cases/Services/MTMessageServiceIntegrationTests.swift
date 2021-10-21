//
//  MTMessageServiceIntegrationTests.swift
//  
//
//  Created by Waseem Akram on 16/09/21.
//

import Foundation
import XCTest
@testable import MailTMSwift

class MTMessageServiceIntegrationTests: XCTestCase {

    var mockTask: MockDataTask!
    var mockApi: MockAPIService!
    var sut: MTMessageService!

    override func setUp() {
        super.setUp()
        mockTask = MockDataTask()
        mockApi = MockAPIService(task: mockTask)
        sut = MTMessageService(apiService: mockApi)
    }

    override func tearDown() {
        mockTask = nil
        mockApi = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Given

    func getMTMessage(id: String = "12345") -> MTMessage {
        MTMessage(id: id,
                  msgid: "123",
                  from: .init(address: "fromUserAddress@example.com",
                              name: "fromUser"),
                  to: [],
                  cc: [],
                  bcc: [],
                  subject: "Testing",
                  seen: false,
                  flagged: false,
                  isDeleted: false,
                  retention: false,
                  retentionDate: .init(),
                  intro: "test-intro",
                  text: "Test message",
                  html: [],
                  hasAttachments: true,
                  attachments: [],
                  size: 0,
                  downloadURL: "",
                  createdAt: .init(),
                  updatedAt: .init())
    }

    // MARK: - getAllMessages Test Cases

    func test_getAllMessages_whenSuccess_returnsMTMessageList() throws {
        typealias ReturningDataType = [MTMessage]
        typealias ResultType = Result<ReturningDataType, MTError>
        typealias HydraResultType = Result<HydraWrapper<ReturningDataType>, MTError>

        // given
        let givenToken = "fakeToken"
        let givenMessage = getMTMessage()

        let givenMessages = [ givenMessage ]
        let givenSuccessResult: HydraResultType = .success(.init(context: "", id: "", type: "", result: givenMessages, hydraTotalItems: 1))

        mockApi.givenResult(result: givenSuccessResult)

        // when
        let resultExpectation = expectation(description: "Did not return the result")
        var returnedResultOptional: ResultType?
        sut.getAllMessages(page: 1, token: givenToken) {(result: ResultType) in
            returnedResultOptional = result
            resultExpectation.fulfill()
        }

        // then
        XCTAssertEqual(mockApi.endpoint, "\(Endpoints.messages)?page=1")
        XCTAssertEqual(mockApi.getAuthToken, givenToken)
        XCTAssertEqual(mockApi.headers, [:])
        XCTAssertEqual(mockApi.getCallCount, 1)
        XCTAssertEqual(mockTask.cancelCallCount, 0)
        waitForExpectations(timeout: 1)
        XCTAssertNotNil(returnedResultOptional)
        let returnedResult = try XCTUnwrap(returnedResultOptional)
        switch returnedResult {
        case .success(let result):
            XCTAssertEqual(result.count, givenMessages.count)
            XCTAssertEqual(result[0].id, givenMessage.id)
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }

    func test_getAllMessages_whenFailure_returnsError() throws {
        typealias ReturningDataType = [MTMessage]
        typealias ResultType = Result<ReturningDataType, MTError>
        typealias HydraResultType = Result<HydraWrapper<ReturningDataType>, MTError>

        // given
        let givenToken = "fakeToken"
        let givenErrorMessage = "Test Error"
        let givenResult: HydraResultType = .failure(.mtError(givenErrorMessage))

        mockApi.givenResult(result: givenResult)

        // when
        let resultExpectation = expectation(description: "Did not return the result")
        var returnedResultOptional: ResultType?
        sut.getAllMessages(page: 1, token: givenToken) {(result: ResultType) in
            returnedResultOptional = result
            resultExpectation.fulfill()
        }

        // then
        XCTAssertEqual(mockApi.endpoint, "\(Endpoints.messages)?page=1")
        XCTAssertEqual(mockApi.getAuthToken, givenToken)
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

    // MARK: - getMessage Test Cases

    func test_getMessage_whenSuccess_returnsMTMessage() throws {
        typealias ResultType = Result<MTMessage, MTError>

        // given
        let givenId = "Asd312"
        let givenToken = "fakeToken"
        let givenMessage = getMTMessage(id: givenId)

        let givenSuccessResult: ResultType = .success(givenMessage)

        mockApi.givenResult(result: givenSuccessResult)

        // when
        let resultExpectation = expectation(description: "Did not return the result")
        var returnedResultOptional: ResultType?
        sut.getMessage(id: givenId, token: givenToken) { (result: ResultType) in
            returnedResultOptional = result
            resultExpectation.fulfill()
        }

        // then
        XCTAssertEqual(mockApi.endpoint, Endpoints.messagesFromId(givenId))
        XCTAssertEqual(mockApi.getAuthToken, givenToken)
        XCTAssertEqual(mockApi.headers, [:])
        XCTAssertEqual(mockApi.getCallCount, 1)
        XCTAssertEqual(mockTask.cancelCallCount, 0)
        waitForExpectations(timeout: 1)
        XCTAssertNotNil(returnedResultOptional)
        let returnedResult = try XCTUnwrap(returnedResultOptional)
        switch returnedResult {
        case .success(let result):
            XCTAssertEqual(result.id, givenMessage.id)
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }

    func test_getMessage_whenFailure_returnsError() throws {
        typealias ResultType = Result<MTMessage, MTError>

        // given
        let givenId = "Asd312"
        let givenToken = "fakeToken"
        let givenErrorMessage = "Test Error"
        let givenResult: ResultType = .failure(.mtError(givenErrorMessage))

        mockApi.givenResult(result: givenResult)

        // when
        let resultExpectation = expectation(description: "Did not return the result")
        var returnedResultOptional: ResultType?
        sut.getMessage(id: givenId, token: givenToken) {(result: ResultType) in
            returnedResultOptional = result
            resultExpectation.fulfill()
        }

        // then
        XCTAssertEqual(mockApi.endpoint, Endpoints.messagesFromId(givenId))
        XCTAssertEqual(mockApi.getAuthToken, givenToken)
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

    // MARK: - deleteMessage Test Cases

    func test_deleteMessage_whenSuccess_returnsMTMessage() throws {
        typealias ResultType = Result<MTEmptyResult, MTError>

        // given
        let givenId = "Asd312"
        let givenToken = "fakeToken"

        let givenSuccessResult: ResultType = .success(.init())

        mockApi.givenResult(result: givenSuccessResult)

        // when
        let resultExpectation = expectation(description: "Did not return the result")
        var returnedResultOptional: ResultType?
        sut.deleteMessage(id: givenId, token: givenToken) { (result: ResultType) in
            returnedResultOptional = result
            resultExpectation.fulfill()
        }

        // then
        XCTAssertEqual(mockApi.endpoint, Endpoints.messagesFromId(givenId))
        XCTAssertEqual(mockApi.requestAuthToken, givenToken)
        XCTAssertEqual(mockApi.headers, [:])
        XCTAssertEqual(mockApi.requestMethod, .delete)
        XCTAssertEqual(mockApi.requestCallCount, 1)
        XCTAssertEqual(mockTask.cancelCallCount, 0)
        waitForExpectations(timeout: 1)
        XCTAssertNotNil(returnedResultOptional)
        let returnedResult = try XCTUnwrap(returnedResultOptional)
        switch returnedResult {
            case .success( _):
            // success
                break
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }

    func test_deleteMessage_whenFailure_returnsError() throws {
        typealias ResultType = Result<MTEmptyResult, MTError>

        // given
        let givenId = "Asd312"
        let givenToken = "fakeToken"
        let givenErrorMessage = "Test Error"
        let givenResult: ResultType = .failure(.mtError(givenErrorMessage))

        mockApi.givenResult(result: givenResult)

        // when
        let resultExpectation = expectation(description: "Did not return the result")
        var returnedResultOptional: ResultType?
        sut.deleteMessage(id: givenId, token: givenToken) {(result: ResultType) in
            returnedResultOptional = result
            resultExpectation.fulfill()
        }

        // then
        XCTAssertEqual(mockApi.endpoint, Endpoints.messagesFromId(givenId))
        XCTAssertEqual(mockApi.requestAuthToken, givenToken)
        XCTAssertEqual(mockApi.headers, [:])
        XCTAssertEqual(mockApi.requestMethod, .delete)
        XCTAssertEqual(mockApi.requestCallCount, 1)
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

    // MARK: - markMessageAsSeen Test Cases

    func test_markMessageAsSeen_whenSuccess_returnsMTMessage() throws {
        typealias ResultType = Result<MTMessage, MTError>

        // given
        let givenId = "Asd312"
        let givenToken = "fakeToken"
        let givenMessage = getMTMessage(id: givenId)

        let givenSuccessResult: ResultType = .success(givenMessage)

        mockApi.givenResult(result: givenSuccessResult)

        // when
        let resultExpectation = expectation(description: "Did not return the result")
        var returnedResultOptional: ResultType?
        sut.markMessageAs(id: givenId, seen: true, token: givenToken) { (result: ResultType) in
            returnedResultOptional = result
            resultExpectation.fulfill()
        }

        // then
        XCTAssertEqual(mockApi.endpoint, Endpoints.messagesFromId(givenId))
        XCTAssertEqual(mockApi.requestAuthToken, givenToken)
        XCTAssertEqual(mockApi.headers, ["Content-Type": "application/merge-patch+json"])
        XCTAssertEqual(mockApi.requestMethod, .patch)
        XCTAssertEqual(mockApi.requestCallCount, 1)
        XCTAssertEqual(mockTask.cancelCallCount, 0)

        let requestBody = try XCTUnwrap(mockApi.requestBody as? [String: Bool])
        XCTAssertEqual(requestBody["seen"], true)

        waitForExpectations(timeout: 1)
        XCTAssertNotNil(returnedResultOptional)
        let returnedResult = try XCTUnwrap(returnedResultOptional)
        switch returnedResult {
        case .success(let result):
            XCTAssertEqual(result.id, givenMessage.id)
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }

    func test_markMessageAsSeen_whenFailure_returnsError() throws {
        typealias ResultType = Result<MTMessage, MTError>

        // given
        let givenId = "Asd312"
        let givenToken = "fakeToken"
        let givenErrorMessage = "Test Error"
        let givenResult: ResultType = .failure(.mtError(givenErrorMessage))

        mockApi.givenResult(result: givenResult)

        // when
        let resultExpectation = expectation(description: "Did not return the result")
        var returnedResultOptional: ResultType?
        sut.markMessageAs(id: givenId, seen: true, token: givenToken) {(result: ResultType) in
            returnedResultOptional = result
            resultExpectation.fulfill()
        }

        // then
        XCTAssertEqual(mockApi.endpoint, Endpoints.messagesFromId(givenId))
        XCTAssertEqual(mockApi.requestAuthToken, givenToken)
        XCTAssertEqual(mockApi.headers, ["Content-Type": "application/merge-patch+json"])
        XCTAssertEqual(mockApi.requestMethod, .patch)
        XCTAssertEqual(mockApi.requestCallCount, 1)
        XCTAssertEqual(mockTask.cancelCallCount, 0)

        let requestBody = try XCTUnwrap(mockApi.requestBody as? [String: Bool])
        XCTAssertEqual(requestBody["seen"], true)

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
