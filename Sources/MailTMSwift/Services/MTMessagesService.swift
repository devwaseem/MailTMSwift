//
//  MTMessageService.swift
//  
//
//  Created by Waseem Akram on 15/09/21.
//

import Foundation

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
    public func getAllMessages(token: String,
                               page: Int = 1,
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
                completion(.success(data.result))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    @discardableResult
    public func deleteMessage(token: String, id: String, completion: @escaping (Result<MTMessage, MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        apiService.request(method: .delete,
                           endpoint: Endpoints.messagesFromId(id),
                           authToken: token,
                           headers: [:],
                           body: EmptyBody(),
                           completion: completion)
    }

    @discardableResult
    public func getMessage(token: String, id: String, completion: @escaping (Result<MTMessage, MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        apiService.get(endpoint: Endpoints.messagesFromId(id), authToken: token, headers: [:], completion: completion)
    }

    @discardableResult
    public func markMessageAs(seen: Bool,
                              token: String,
                              id: String,
                              completion: @escaping (Result<MTMessage, MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        apiService.request(method: .patch,
                           endpoint: Endpoints.messagesFromId(id),
                           authToken: token,
                           headers: [:],
                           body: ["seen": seen],
                           completion: completion)
    }

}
