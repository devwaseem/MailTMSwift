//
//  MockAPIService.swift
//  
//
//  Created by Waseem Akram on 15/09/21.
//

import Foundation
import Combine
@testable import MailTMSwift

class MockDataTask: MTAPIServiceTaskProtocol {

    var taskId: UUID

    init (taskId: UUID = .init()) {
        self.taskId = taskId
    }

    var cancelCallCount = 0
    func cancel() {
        cancelCallCount += 1
    }

}

class MockAPIService: APIServiceProtocol {

    private var returningResult: Any!
    private var task: MockDataTask
    private(set) var endpoint = ""
    private(set) var headers: [String: String] = [:]

    init(task: MockDataTask) {
        self.task = task
    }

    func givenResult<T: Decodable>(result: Result<T, MTError>) {
        self.returningResult = result
    }

    func givenTask(mockDataTask: MockDataTask) {
        self.task = mockDataTask
    }

    private(set) var getCallCount = 0
    private(set) var getAuthToken: String?
    func get<T>(endpoint: String, authToken: String?, headers: [String: String], completion: @escaping APIResultClosure<T>) -> MTAPIServiceTaskProtocol where T: Decodable {
        self.getCallCount += 1
        self.getAuthToken = authToken
        self.endpoint = endpoint
        self.headers = headers
        completion(returningResult as! Result<T, MTError>)
        return task
    }

    private(set) var requestCallCount = 0
    private(set) var requestMethod: APIRequestMethod!
    private(set) var requestAuthToken: String!
    private(set) var requestCancelCallCount = 0
    private(set) var requestBody: Any!
    func request<In, Res>(method: APIRequestMethod, endpoint: String, authToken: String?, headers: [String: String], body: In?, completion: @escaping APIResultClosure<Res>) -> MTAPIServiceTaskProtocol where In: Encodable, Res: Decodable {
        self.requestCallCount += 1
        self.requestMethod = method
        self.requestAuthToken = authToken
        self.endpoint = endpoint
        self.headers = headers
        self.requestBody = body
        completion(returningResult as! Result<Res, MTError>)
        return task
    }

    private(set) var getPublisherCallCount = 0
    private(set) var getPublisherAuthToken: String?
    @available(iOS 13.0, *)
    func get<T>(endpoint: String, authToken: String?, headers: [String: String]) -> AnyPublisher<T, MTError> where T: Decodable {
        self.getCallCount += 1
        self.getAuthToken = authToken
        self.endpoint = endpoint
        self.headers = headers
        let result = returningResult as! Result<T, MTError>

        return Deferred {
            Future { promise in
                switch result {
                    case .success(let data):
                        promise(.success(data))
                    case .failure(let error):
                        promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private(set) var requestPublisherCallCount = 0
    private(set) var requestPublisherMethod: APIRequestMethod!
    private(set) var requestPublisherAuthToken: String!
    private(set) var requestPublisherCancelCallCount = 0
    private(set) var requestPublisherBody: Any!
    @available(iOS 13.0, *)
    func request<T, E>(method: APIRequestMethod, endpoint: String, authToken: String?, headers: [String: String], body: E?) -> AnyPublisher<T, MTError> where T: Decodable, E: Encodable {
        self.requestPublisherCallCount += 1
        self.requestPublisherMethod = method
        self.requestPublisherAuthToken = authToken
        self.endpoint = endpoint
        self.headers = headers
        self.requestPublisherBody = body
        let result = returningResult as! Result<T, MTError>

        return Deferred {
            Future { promise in
                switch result {
                    case .success(let data):
                        promise(.success(data))
                    case .failure(let error):
                        promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

}
