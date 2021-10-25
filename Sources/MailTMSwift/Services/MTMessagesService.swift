//
//  MTMessageService.swift
//  
//
//  Created by Waseem Akram on 15/09/21.
//

import Foundation
import Combine

/// Helper class to work with [Mail.tm](https://mail.tm) messages
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

    /// Retrieve all Messages for an account
    /// - Parameters:
    ///   - page: pagination page number
    ///   - token: account JWT token
    ///   - completion: when successful, returns a completion handler `Result` type of array of``MTMessage`` and ``MTError`` if some error occurred
    /// - Returns: ServiceTask which can be used to cancel on-going http(s) request
    ///
    /// Example:
    /// ```swift
    /// let messageService = MTMessageService()
    /// let token = // Account JWT token
    /// messageService.getAllMessages(token: token) { (result: Result<[MTMessage], MTError>) in
    ///     switch result {
    ///       case .success(let messages):
    ///             for message in messages {
    ///                 print("Message: \(message)")
    ///             }
    ///       case .failure(let error):
    ///         print("Error occurred \(error)")
    ///     }
    /// }
    /// ```
    /// - Note: The messages returned by this method does not contain complete information, because it is intended to list the messages as list. To fetch the complete message with the complete information, use ``MTMessageService/getMessage(id:token:)``
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
    
    /// Delete a message
    /// - Parameters:
    ///   - id: message id
    ///   - token: account JWT token
    ///   - completion: when successful, returns a completion handler `Result` type of ``MTEmptyResult`` and ``MTError`` if some error occurred
    /// - Returns: ServiceTask which can be used to cancel on-going http(s) request
    ///
    /// Example:
    /// ```swift
    /// let messageService = MTMessageService()
    /// let id = // Message ID
    /// let token = // Account JWT token
    /// messageService.deleteMessage(id: id, token: token) { (result: Result<MTEmptyResult, MTError>) in
    ///     if case let .failure(error) = result {
    ///         print("Error Occurred: \(error)")
    ///         return
    ///     }
    ///
    ///     // Message deleted
    ///     doSomethingAfterDelete()
    /// }
    /// ```
    /// - Note: When a message is successfully deleted, the server sends a empty response.
    @discardableResult
    public func deleteMessage(id: String, token: String, completion: @escaping (Result<MTEmptyResult, MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        apiService.request(method: .delete,
                           endpoint: Endpoints.messagesFromId(id),
                           authToken: token,
                           headers: [:],
                           body: MTEmptyBody(),
                           completion: completion)
    }

    /// Retrieve a message using its id
    /// - Parameters:
    ///   - id: message id
    ///   - token: account JWT token
    ///   - completion: when successful, returns a completion handler `Result` type of ``MTMessage`` and ``MTError`` if some error occurred
    /// - Returns: ServiceTask which can be used to cancel on-going http(s) request
    ///
    /// Example:
    /// ```swift
    /// let messageService = MTMessageService()
    /// let id = // Message ID
    /// let token = // Account JWT token
    /// messageService.getMessage(id: id, token: token) { (result: Result<MTMessage, MTError>) in
    ///     switch result {
    ///       case .success(let message):
    ///         print("Complete message: \(message)")
    ///       case .failure(let error):
    ///         print("Error occurred \(error)")
    ///     }
    /// }
    /// ```
    @discardableResult
    public func getMessage(id: String, token: String, completion: @escaping (Result<MTMessage, MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        apiService.get(endpoint: Endpoints.messagesFromId(id), authToken: token, headers: [:], completion: completion)
    }

    /// Mark message as seen/unseen
    /// - Parameters:
    ///   - id: message id
    ///   - seen: a boolean indicating seen/unseen
    ///   - token: account JWT Token
    ///   - completion: when successful, returns a completion handler `Result` type of ``MTMessage`` and ``MTError`` if some error occurred
    /// - Returns: ServiceTask which can be used to cancel on-going http(s) request
    ///
    /// Example:
    /// ```swift
    /// let messageService = MTMessageService()
    /// let id = // Message ID
    /// let token = // Account JWT token
    /// messageService.markMessageAs(id: id, seen: true, token: token) { (result: Result<MTMessage, MTError>) in
    ///     switch result {
    ///       case .success(let message):
    ///         print("Updated message: \(message)")
    ///       case .failure(let error):
    ///         print("Error occurred \(error)")
    ///     }
    /// }
    /// ```
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
    
    /// Get source for a message.
    /// - Parameters:
    ///   - id: message id
    ///   - token: account JWT token
    ///   - completion: when successful, returns a completion handler `Result` type of ``MTMessageSource`` and ``MTError`` if some error occurred
    /// - Returns: ServiceTask which can be used to cancel on-going http(s) request
    ///
    /// Example:
    ///
    /// ```swift
    /// let messageService = MTMessageService()
    /// let id = // Message ID
    /// let token = // Account JWT token
    /// messageService.getSource(id: id, token: token) { (result: Result<MTMessageSource, MTError>) in
    ///     switch result {
    ///       case .success(let messageSource):
    ///         print("Message source: \(messageSource)")
    ///       case .failure(let error):
    ///         print("Error occurred \(error)")
    ///     }
    /// }
    /// ```
    @discardableResult
    public func getSource(id: String,
                          token: String,
                          completion: @escaping (Result<MTMessageSource, MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        apiService.get(endpoint: Endpoints.sourcesFromId(id), authToken: token, headers: [:], completion: completion)
    }
    
    /// Retrieve all Messages for an account
    /// - Parameters:
    ///   - page: pagination page number
    ///   - token: account JWT token
    /// - Returns: A publisher that emits an array of ``MTMessage`` when the messages for given account is successfully retreived.
    /// - Note: Messages received will not be complete. Use the retreived messages to show a list of messages.
    ///         To retreive the complete message, use ``MTMessageService/getMessage(id:token:)``.
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
    
    /// Delete a message
    /// - Parameters:
    ///   - id: message id
    ///   - token: account JWT token
    /// - Returns: A publisher that emits ``MTEmptyResult`` when account is deleted successfully.
    /// - Note: When a message is successfully deleted, the server sends a empty response.
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

    /// Retrieve a message using its id
    /// - Parameters:
    ///   - id: message id
    ///   - token: account JWT token
    /// - Returns: A publisher that emits ``MTMessage`` when the message is retreived successfully.
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
    /// Mark message as seen/unseen
    /// - Parameters:
    ///   - id: message id
    ///   - seen: a boolean indicating seen/unseen
    ///   - token: account JWT Token
    /// - Returns: A publisher that emits ``MTMessage`` when the message is updated successfully.
    public func markMessageAs(id: String,
                              seen: Bool,
                              token: String) -> AnyPublisher<MTMessage, MTError> {
        apiService.request(method: .patch,
                           endpoint: Endpoints.messagesFromId(id),
                           authToken: token,
                           headers: ["Content-Type": "application/merge-patch+json"],
                           body: ["seen": seen])
    }
    
    /// Get source for a message.
    /// - Parameters:
    ///   - id: message id
    ///   - token: account JWT token
    /// - Returns: A publisher that emits ``MTMessageSource`` when the message source is retreived successfully.
    @available(macOS 10.15, *)
    @available(iOS 13.0, *)
    @available(watchOS 6.0, *)
    @available(tvOS 13.0, *)
    public func getSource(id: String,
                          token: String) -> AnyPublisher<MTMessageSource, MTError> {
        apiService.get(endpoint: Endpoints.sourcesFromId(id), authToken: token, headers: [:])
    }
    
    /// Get `URLRequest` for message source.
    /// - Parameters:
    ///   - id: message id
    ///   - token: account JWT Token
    /// - Returns: `URLRequest` configured to retreive message source.
    ///
    /// If the size of message is big and you wish to use a downloadTask from URLSession, you can do so manually by using the URLRequest object returned by:
    /// ```swift
    /// let messageService = MTMessageService()
    /// let id = // Message ID
    /// let token = // Account JWT token
    /// let urlRequest = messageService.getSourceRequest(id: id, token: token)
    /// let task = URLSession.shared.downloadTask(with: request)
    /// // handle download task
    /// ```
    ///
    /// - Note: This method will return nil, if the message source url is nil.
    public func getSourceRequest(id: String, token: String) -> URLRequest? {
        guard let url = URL(string: Endpoints.sourcesFromId(id)) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ["Authorization": "Bearer \(token)"]
        request.httpMethod = "GET"
        return request
    }

}
