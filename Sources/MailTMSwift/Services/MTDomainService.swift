//
//  MTDomainService.swift
//  
//
//  Created by Waseem Akram on 15/09/21.
//

import Foundation
import Combine

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

    @discardableResult
    open func getDomain(id: String, completion: @escaping (Result<MTDomain, MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        apiService.get(endpoint: Endpoints.domainFromId(id), authToken: nil, headers: [:], completion: completion)
    }

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

    @available(macOS 10.15, *)
    @available(iOS 13.0, *)
    @available(watchOS 6.0, *)
    @available(tvOS 13.0, *)
    open func getDomain(id: String) -> AnyPublisher<MTDomain, MTError> {
        apiService.get(endpoint: Endpoints.domainFromId(id), authToken: nil, headers: [:])
    }

}
