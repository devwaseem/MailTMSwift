//
//  APIService+Combine.swift
//  
//
//  Created by Waseem Akram on 28/09/21.
//

import Foundation
import Combine

@available(macOS 10.15, *)
@available(iOS 13.0, *)
@available(watchOS 6.0, *)
@available(tvOS 13.0, *)
extension APIService {
    func get<T: Decodable>(endpoint: String, authToken: String? = nil, headers: [String: String] = [:]) -> AnyPublisher<T, MTError> {
        MTAPIServiceGetPublisher(apiService: self, endpoint: endpoint, authToken: authToken, headers: [:])
            .eraseToAnyPublisher()
    }

    func request<T: Decodable, E: Encodable>(method: APIRequestMethod, endpoint: String, authToken: String? = nil, headers: [String: String] = [:], body: E?)  -> AnyPublisher<T, MTError> {
        MTAPIServiceRequestPublisher(apiService: self, method: method, endpoint: endpoint, authToken: authToken, headers: headers, body: body)
            .eraseToAnyPublisher()
    }
}

// MARK: - Get Publishers

@available(macOS 10.15, *)
@available(iOS 13.0, *)
@available(watchOS 6.0, *)
@available(tvOS 13.0, *)
struct MTAPIServiceGetPublisher<T: Decodable>: Publisher {

    typealias Output = T
    typealias Failure = MTError

    let apiService: APIService
    let endpoint: String
    let authToken: String?
    let headers: [String: String]

    init(apiService: APIService, endpoint: String, authToken: String?, headers: [String: String]) {
        self.apiService = apiService
        self.endpoint = endpoint
        self.authToken = authToken
        self.headers = headers
    }

    func receive<S>(subscriber: S) where S: Subscriber, MTError == S.Failure, Output == S.Input {
        let subscription = MTAPIServiceGetSubscription(subscriber: subscriber,
                                                    apiService: apiService,
                                                    endpoint: endpoint,
                                                    authToken: authToken,
                                                    headers: headers)
        subscriber.receive(subscription: subscription)
    }

}

@available(macOS 10.15, *)
@available(iOS 13.0, *)
@available(watchOS 6.0, *)
@available(tvOS 13.0, *)
final class MTAPIServiceGetSubscription<S: Subscriber, T: Decodable>: Subscription where S.Failure == MTError, S.Input == T {

    typealias Output = S.Input

    var subscriber: S?
    let apiService: APIService
    let endpoint: String
    let authToken: String?
    let headers: [String: String]

    var task: MTAPIServiceTaskProtocol?

    init(subscriber: S, apiService: APIService, endpoint: String, authToken: String?, headers: [String: String]) {
        self.subscriber = subscriber
        self.apiService = apiService
        self.endpoint = endpoint
        self.authToken = authToken
        self.headers = headers
    }

    func request(_ demand: Subscribers.Demand) {
        self.task = apiService.get(endpoint: endpoint, authToken: authToken, headers: headers) { (result: Result<T, MTError>) in
            switch result {
                case .failure(let error):
                    self.subscriber?.receive(completion: .failure(error))
                case .success(let data):
                    _ = self.subscriber?.receive(data)
                    self.subscriber?.receive(completion: .finished)
            }
        }
    }

    func cancel() {
        self.task?.cancel()
        self.task = nil
        self.subscriber = nil
    }

}

// MARK: - Request Publishers

@available(macOS 10.15, *)
@available(iOS 13.0, *)
@available(watchOS 6.0, *)
@available(tvOS 13.0, *)
struct MTAPIServiceRequestPublisher<T: Decodable, E: Encodable>: Publisher {

    typealias Output = T
    typealias Failure = MTError

    let apiService: APIService
    let method: APIRequestMethod
    let endpoint: String
    let authToken: String?
    let headers: [String: String]
    let body: E?

    init(apiService: APIService, method: APIRequestMethod, endpoint: String, authToken: String?, headers: [String: String], body: E?) {
        self.apiService = apiService
        self.endpoint = endpoint
        self.authToken = authToken
        self.headers = headers
        self.method = method
        self.body = body
    }

    func receive<S>(subscriber: S) where S: Subscriber, MTError == S.Failure, Output == S.Input {
        let subscription = MTAPIServiceRequestSubscription(subscriber: subscriber, apiService: apiService, method: method, endpoint: endpoint, authToken: authToken, headers: headers, body: body)
        subscriber.receive(subscription: subscription)
    }

}

@available(macOS 10.15, *)
@available(iOS 13.0, *)
@available(watchOS 6.0, *)
@available(tvOS 13.0, *)
final class MTAPIServiceRequestSubscription<S: Subscriber, T: Decodable, E: Encodable>: Subscription where S.Failure == MTError, S.Input == T {

    typealias Output = S.Input

    var subscriber: S?
    let apiService: APIService
    let method: APIRequestMethod
    let endpoint: String
    let authToken: String?
    let headers: [String: String]
    let body: E?

    var task: MTAPIServiceTaskProtocol?

    init(subscriber: S, apiService: APIService, method: APIRequestMethod, endpoint: String, authToken: String?, headers: [String: String], body: E?) {
        self.subscriber = subscriber
        self.apiService = apiService
        self.method = method
        self.endpoint = endpoint
        self.authToken = authToken
        self.headers = headers
        self.body = body
    }

    func request(_ demand: Subscribers.Demand) {

        self.task = apiService.request(method: method, endpoint: endpoint, authToken: authToken, headers: headers, body: body) { (result: Result<T, MTError>) in
            switch result {
                case .failure(let error):
                    self.subscriber?.receive(completion: .failure(error))
                case .success(let data):
                    _ = self.subscriber?.receive(data)
                    self.subscriber?.receive(completion: .finished)
            }
        }
    }

    func cancel() {
        self.task?.cancel()
        self.task = nil
        self.subscriber = nil
    }

}
