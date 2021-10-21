//
//  MTAccountService.swift
//  
//
//  Created by Waseem Akram on 15/09/21.
//

import Foundation
import Combine

/// Helper class to work with [Mail.tm](https://mail.tm) accounts
open class MTAccountService {

    private let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }

    public init() {
        self.apiService = APIService(session: .shared,
                                     encoder: MTJSONEncoder(),
                                     decoder: MTJSONDecoder())
    }

    /// Generate JWT token for an account
    /// - Parameters:
    ///   - auth: ``MTAuth`` struct which holds address and password
    ///   - completion: when successful, returns a `Result` type with JWT token string and ``MTError`` if some error occurred
    /// - Returns: ServiceTask which can be used to cancel on-going http(s) request
    @discardableResult
    open func login(using auth: MTAuth, completion: @escaping (Result<String, MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        apiService.request(method: .post,
                           endpoint: Endpoints.token,
                           authToken: nil,
                           headers: [:],
                           body: auth) { (result: Result<MTToken, MTError>) in
            switch result {
            case .success(let token):
                completion(.success(token.token))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    
    /// Creates an account using address and password
    /// - Parameters:
    ///   - auth: ``MTAuth`` struct which holds address and password
    ///   - completion: when successful, returns a `Result` type with ``MTAccount`` and ``MTError`` if some error occurred
    /// - Returns: ServiceTask which can be used to cancel on-going http(s) request
    @discardableResult
    open func createAccount(using auth: MTAuth, completion: @escaping (Result<MTAccount, MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        apiService.request(
            method: .post,
            endpoint: Endpoints.account,
            authToken: nil,
            headers: [:],
            body: auth,
            completion: completion)
    }

    /// Retreive your account using JWT token
    /// - Parameters:
    ///   - token: JWT token
    ///   - completion: when successful, returns a `Result` type with ``MTAccount`` and ``MTError`` if some error occurred
    /// - Returns: ServiceTask which can be used to cancel on-going http(s) request
    @discardableResult
    open func getMyAccount(token: String, completion: @escaping (Result<MTAccount, MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        apiService.get(endpoint: Endpoints.myAccount,
                       authToken: token,
                       headers: [:],
                       completion: completion)
    }

    /// Delete account
    /// - Parameters:
    ///   - id: account id
    ///   - token: JWT token
    ///   - completion: when successful, returns a `Result` type with ``MTEmptyResult`` and ``MTError`` if some error occurred
    /// - Returns: ServiceTask which can be used to cancel on-going http(s) request
    ///
    /// - Note: When deletion is successful, the API returns empty response which indicates successful operation.
    @discardableResult
    open func deleteAccount(id: String, token: String, completion: @escaping (Result<MTEmptyResult, MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        apiService.request(method: .delete,
                           endpoint: Endpoints.accountFromId(id),
                           authToken: token,
                           headers: [:],
                           body: MTEmptyBody(),
                           completion: completion)
    }

    /// Generate JWT token for an account
    /// - Parameter auth: ``MTAuth`` struct which holds address and password
    /// - Returns: A publisher that emits JWT token (`String`) when login is successful.
    @available(macOS 10.15, *)
    @available(iOS 13.0, *)
    @available(watchOS 6.0, *)
    @available(tvOS 13.0, *)
    open func login(using auth: MTAuth) -> AnyPublisher<String, MTError> {
        let publisher: AnyPublisher<MTToken, MTError> = apiService
            .request(method: .post,
                     endpoint: Endpoints.token,
                     authToken: nil,
                     headers: [:],
                     body: auth)
        return publisher
            .map(\.token)
            .eraseToAnyPublisher()
    }

    /// Creates an account using address and password
    /// - Parameter auth: ``MTAuth`` struct which holds address and password
    /// - Returns: A publisher that emits ``MTAccount`` when account is created successfully.
    @available(macOS 10.15, *)
    @available(iOS 13.0, *)
    @available(watchOS 6.0, *)
    @available(tvOS 13.0, *)
    open func createAccount(using auth: MTAuth) -> AnyPublisher<MTAccount, MTError> {
        apiService.request(method: .post, endpoint: Endpoints.account, authToken: nil, headers: [:], body: auth)
    }

    /// Retreive your account using JWT token
    /// - Parameter token: JWT token
    /// - Returns: A publisher that emits ``MTAccount`` when account is retreived successfully.
    @available(macOS 10.15, *)
    @available(iOS 13.0, *)
    @available(watchOS 6.0, *)
    @available(tvOS 13.0, *)
    open func getMyAccount(token: String) -> AnyPublisher<MTAccount, MTError> {
        apiService.get(endpoint: Endpoints.myAccount, authToken: token, headers: [:])
    }

    /// Delete account
    /// - Parameters:
    ///   - id: account id
    ///   - token: JWT token
    /// - Returns: A publisher that emits ``MTEmptyResult`` when account is deleted successfully.
    ///
    /// - Note: When deletion is successful, the API returns empty response which indicates successful operation.
    @available(macOS 10.15, *)
    @available(iOS 13.0, *)
    @available(watchOS 6.0, *)
    @available(tvOS 13.0, *)
    open func deleteAccount(id: String, token: String) -> AnyPublisher<MTEmptyResult, MTError> {
        apiService.request(method: .delete, endpoint: Endpoints.accountFromId(id), authToken: token, headers: [:], body: MTEmptyBody())
    }

}
