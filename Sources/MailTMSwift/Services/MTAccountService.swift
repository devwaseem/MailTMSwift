//
//  MTAccountService.swift
//  
//
//  Created by Waseem Akram on 15/09/21.
//

import Foundation
import Combine

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
    
    @discardableResult
    open func login(using auth: MTAuth, completion: @escaping (Result<String, MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        apiService.request(method: .post, endpoint: Endpoints.token, authToken: nil, headers: [:], body: auth) {
            (result: Result<MTToken, MTError>) in
            switch result {
            case .success(let token):
                completion(.success(token.token))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
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
    
    @discardableResult
    open func getMyAccount(token: String, completion: @escaping (Result<MTAccount, MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        apiService.get(endpoint: Endpoints.myAccount,
                       authToken: token,
                       headers: [:],
                       completion: completion)
    }
    
    @discardableResult
    open func deleteAccount(id: String, token: String, completion: @escaping (Result<MTAccount, MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        apiService.request(method: .delete,
                           endpoint: Endpoints.myAccount,
                           authToken: token,
                           headers: [:],
                           body: EmptyBody(),
                           completion: completion)
    }
    
    @available(macOS 10.15, *)
    @available(iOS 13.0, *)
    @available(watchOS 6.0, *)
    @available(tvOS 13.0, *)
    open func login(using auth: MTAuth) -> AnyPublisher<String, MTError> {
        let publisher: AnyPublisher<MTToken, MTError> = apiService.request(method: .post, endpoint: Endpoints.token, authToken: nil, headers: [:], body: auth)
        return publisher
            .map(\.token)
            .eraseToAnyPublisher()
    }
    
    @available(macOS 10.15, *)
    @available(iOS 13.0, *)
    @available(watchOS 6.0, *)
    @available(tvOS 13.0, *)
    open func createAccount(using auth: MTAuth) -> AnyPublisher<MTAccount, MTError> {
        apiService.request(method: .post, endpoint: Endpoints.account, authToken: nil, headers: [:], body: auth)
    }
    
    @available(macOS 10.15, *)
    @available(iOS 13.0, *)
    @available(watchOS 6.0, *)
    @available(tvOS 13.0, *)
    open func getMyAccount(token: String) -> AnyPublisher<MTAccount, MTError> {
        apiService.get(endpoint: Endpoints.myAccount, authToken: token, headers: [:])
    }
    
    @available(macOS 10.15, *)
    @available(iOS 13.0, *)
    @available(watchOS 6.0, *)
    @available(tvOS 13.0, *)
    open func deleteAccount(id: String, token: String) -> AnyPublisher<MTAccount, MTError> {
        apiService.request(method: .delete, endpoint: Endpoints.myAccount, authToken: token, headers: [:], body: EmptyBody())
    }
    
}


