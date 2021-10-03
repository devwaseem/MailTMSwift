//
//  MTMessageService.swift
//  
//
//  Created by Waseem Akram on 15/09/21.
//

import Foundation
import Combine

open class MTMessageService {

    private let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }

    public init() {
        self.apiService = APIService(session: .shared,
                                     encoder: MTJSONEncoder(),
                                     decoder: MTJSONDecoder())
    }

    @discardableResult
    public func getAllMessages(page: Int = 1, token: String,
                               completion: @escaping (Result<[MTMessage], MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        guard var urlComponent = URLComponents(string: Endpoints.messages) else {
            completion(.failure(.networkError("Invalid URL: \(Endpoints.messages)")))
            return APIPlaceholderServiceTask()
        }
        urlComponent.queryItems = [
            URLQueryItem(name: "page", value: String(page))
        ]
        guard let fullUrl = urlComponent.url?.absoluteString else {
            completion(.failure(.networkError("Invalid URL: \(Endpoints.messages)")))
            return APIPlaceholderServiceTask()
        }
        return apiService.get(endpoint: fullUrl, authToken: token, headers: [:]) { (result: Result<HydraWrapper<[MTMessage]>, MTError>) in
            switch result {
            case .success(let data):
                completion(.success(data.result ?? []))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    @discardableResult
    public func deleteMessage(id: String, token: String, completion: @escaping (Result<MTEmptyResult, MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        apiService.request(method: .delete,
                           endpoint: Endpoints.messagesFromId(id),
                           authToken: token,
                           headers: [:],
                           body: MTEmptyBody(),
                           completion: completion)
    }

    @discardableResult
    public func getMessage(token: String, id: String, completion: @escaping (Result<MTMessage, MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        apiService.get(endpoint: Endpoints.messagesFromId(id), authToken: token, headers: [:], completion: completion)
    }

    @discardableResult
    public func markMessageAs(id: String,
                              seen: Bool,
                              token: String,
                              completion: @escaping (Result<MTMessage, MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        apiService.request(method: .patch,
                           endpoint: Endpoints.messagesFromId(id),
                           authToken: token,
                           headers: ["Content-Type": "application/merge-patch+json"],
                           body: ["seen": seen],
                           completion: completion)
    }
    
    @discardableResult
    public func getSource(id: String,
                          token: String,
                          completion: @escaping (Result<MTMessageSource, MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        apiService.get(endpoint: Endpoints.sourcesFromId(id), authToken: token, headers: [:], completion: completion)
    }
    
    @available(macOS 10.15, *)
    @available(iOS 13.0, *)
    @available(watchOS 6.0, *)
    @available(tvOS 13.0, *)
    public func getAllMessages(page: Int = 1,
                               token: String) -> AnyPublisher<[MTMessage], MTError> {
        guard var urlComponent = URLComponents(string: Endpoints.messages) else {
            return Deferred {
                Future { promise in
                    promise(.failure(.networkError("Invalid URL: \(Endpoints.messages)")))
                }
            }.eraseToAnyPublisher()
        }
        
        urlComponent.queryItems = [
            URLQueryItem(name: "page", value: String(page))
        ]
        
        guard let fullUrl = urlComponent.url?.absoluteString else {
            return Deferred {
                Future { promise in
                    promise(.failure(.networkError("Invalid URL: \(Endpoints.messages)")))
                }
            }.eraseToAnyPublisher()
        }
        
        let publisher: AnyPublisher<HydraWrapper<[MTMessage]>, MTError> = apiService.get(endpoint: fullUrl, authToken: token, headers: [:])
        return publisher
            .map(\.result)
            .replaceNil(with: [])
            .eraseToAnyPublisher()
    }
    
    @available(macOS 10.15, *)
    @available(iOS 13.0, *)
    @available(watchOS 6.0, *)
    @available(tvOS 13.0, *)
    public func deleteMessage(id: String, token: String) -> AnyPublisher<MTEmptyResult, MTError> {
        apiService.request(method: .delete,
                           endpoint: Endpoints.messagesFromId(id),
                           authToken: token,
                           headers: [:],
                           body: MTEmptyBody())
    }

    @available(macOS 10.15, *)
    @available(iOS 13.0, *)
    @available(watchOS 6.0, *)
    @available(tvOS 13.0, *)
    public func getMessage(id: String, token: String) -> AnyPublisher<MTMessage, MTError> {
        apiService.get(endpoint: Endpoints.messagesFromId(id), authToken: token, headers: [:])
    }

    @available(macOS 10.15, *)
    @available(iOS 13.0, *)
    @available(watchOS 6.0, *)
    @available(tvOS 13.0, *)
    public func markMessageAs(id: String,
                              seen: Bool,
                              token: String) -> AnyPublisher<MTMessage, MTError> {
        apiService.request(method: .patch,
                           endpoint: Endpoints.messagesFromId(id),
                           authToken: token,
                           headers: ["Content-Type": "application/merge-patch+json"],
                           body: ["seen": seen])
    }
    
    @available(macOS 10.15, *)
    @available(iOS 13.0, *)
    @available(watchOS 6.0, *)
    @available(tvOS 13.0, *)
    public func getSource(id: String,
                          token: String) -> AnyPublisher<MTMessageSource, MTError> {
        apiService.get(endpoint: Endpoints.sourcesFromId(id), authToken: token, headers: [:])
    }

}
