//
//  MTDomainService.swift
//  
//
//  Created by Waseem Akram on 15/09/21.
//

import Foundation
import Combine

/// Helper class to retreive [Mail.tm](https://mail.tm) domains
open class MTDomainService {

    private let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }

    public init() {
        self.apiService = APIService(session: .shared,
                                     encoder: MTJSONEncoder(),
                                     decoder: MTJSONDecoder())
    }

    
    /// Get all domains that [Mail.tm](https://mail.tm) offers
    /// - Parameter completion: when successful, returns a `Result` type with the list of ``MTDomain`` and ``MTError`` if some error occurred
    /// - Returns: ServiceTask which can be used to cancel on-going http(s) request
    @discardableResult
    open func getAllDomains(completion: @escaping (Result<[MTDomain], MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        apiService.get(endpoint: Endpoints.domains, authToken: nil, headers: [:]) { (result: Result<HydraWrapper<[MTDomain]>, MTError>) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                completion(.success(data.result ?? []))
            }
        }
    }

    /// Get domains using id that [Mail.tm](https://mail.tm) offers
    /// - Parameters:
    ///   - id: domain id
    ///   - completion: when successful, returns a `Result` type with ``MTDomain`` and ``MTError`` if some error occurred
    /// - Returns: ServiceTask which can be used to cancel on-going http(s) request
    @discardableResult
    open func getDomain(id: String, completion: @escaping (Result<MTDomain, MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        apiService.get(endpoint: Endpoints.domainFromId(id), authToken: nil, headers: [:], completion: completion)
    }

    /// Get all domains that Mail.tm offers
    /// - Returns: A publisher that emits array of ``MTDomain``.
    @available(macOS 10.15, *)
    @available(iOS 13.0, *)
    @available(watchOS 6.0, *)
    @available(tvOS 13.0, *)
    open func getAllDomains() -> AnyPublisher<[MTDomain], MTError> {
        let publisher: AnyPublisher<HydraWrapper<[MTDomain]>, MTError> = apiService.get(endpoint: Endpoints.domains, authToken: nil, headers: [:])
        return publisher
            .map(\.result)
            .replaceNil(with: [])
            .eraseToAnyPublisher()
    }

    /// Get domains using id that [Mail.tm](https://mail.tm) offers
    /// - Parameter id: domain id
    /// - Returns: A publisher that emits ``MTDomain``.
    @available(macOS 10.15, *)
    @available(iOS 13.0, *)
    @available(watchOS 6.0, *)
    @available(tvOS 13.0, *)
    open func getDomain(id: String) -> AnyPublisher<MTDomain, MTError> {
        apiService.get(endpoint: Endpoints.domainFromId(id), authToken: nil, headers: [:])
    }

}
