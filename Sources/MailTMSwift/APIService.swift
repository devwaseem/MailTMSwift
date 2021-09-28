//
//  File.swift
//  
//
//  Created by Waseem Akram on 15/09/21.
//

import Foundation
import Combine

enum APIRequestMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
         
}

struct EmptyBody: Codable {
    
}

typealias APIResultClosure<T> = (Result<T, MTError>) -> Void

protocol APIServiceProtocol {
    
    @discardableResult
    func get<T: Decodable>(endpoint: String,
                           authToken: String?,
                           headers: [String: String],
                           completion: @escaping APIResultClosure<T>) -> MTAPIServiceTaskProtocol
    @discardableResult
    func request<In: Encodable, Res: Decodable>(method: APIRequestMethod,
                                                endpoint: String,
                                                authToken: String?,
                                                headers: [String: String],
                                                body: In?,
                                                completion: @escaping APIResultClosure<Res>) -> MTAPIServiceTaskProtocol
    
    @available(tvOS 13.0, *)
    @available(macOS 10.15, *)
    @available(iOS 13.0, *)
    @available(watchOS 6.0, *)
    func get<T: Decodable>(endpoint: String, authToken: String?, headers: [String: String]) -> AnyPublisher<T, MTError>
    
    @available(macOS 10.15, *)
    @available(iOS 13.0, *)
    @available(watchOS 6.0, *)
    @available(tvOS 13.0, *)
    func request<T: Decodable, E: Encodable>(method: APIRequestMethod, endpoint: String, authToken: String?, headers: [String: String], body: E?)  -> AnyPublisher<T, MTError>
}

final class APIService: APIServiceProtocol {
        
    let encoder: JSONEncoder
    let decoder: JSONDecoder
    let session: URLSession
    
    init(session: URLSession = .shared, encoder: JSONEncoder = .init(), decoder: JSONDecoder = .init()) {
        self.encoder = encoder
        self.decoder = decoder
        self.session = session
        if #available(macOS 10.13, *),
           #available(iOS 11.0, *),
           #available(tvOS 11.0, *),
           #available(watchOS 4.0, *) {
            self.session.configuration.waitsForConnectivity = true
        }
    }
    
    @discardableResult
    func get<T: Decodable>(endpoint: String, authToken: String? = nil, headers: [String: String] = [:], completion: @escaping APIResultClosure<T>) -> MTAPIServiceTaskProtocol {
        guard let url = URL(string: endpoint) else {
            fatalError("Invalid url passed: \(endpoint)")
        }
        var headers = headers
        if let token = authToken {
            headers["Authorization"] = "Bearer \(token)"
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            self.handleAPIOutput(data: data, response: response, error: error, completion: completion)
        }
        
        task.resume()
        return MTAPIServiceTask(sessionTask: task)
    }
    
    @discardableResult
    func request<In: Encodable, Res: Decodable>(method: APIRequestMethod = .post, endpoint: String,  authToken: String? = nil, headers: [String: String] = [:], body: In?, completion: @escaping APIResultClosure<Res>) -> MTAPIServiceTaskProtocol {
        guard let url = URL(string: endpoint) else {
            fatalError("Invalid url passed: \(endpoint)")
        }
        var headers = headers
        if let token = authToken {
            headers["Authorization"] = "Bearer \(token)"
        }
        headers["Content-Type"] = "application/json"
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        if let body = body {
            do {
                request.httpBody = try encoder.encode(body)
            } catch let encoderError {
                completion(.failure(.decodingError(encoderError.localizedDescription)))
            }
        }
        return bodyTypeRequest(request: request, completion: completion)
    }
    
    internal func handleAPIOutput<T: Decodable>(data: Data?, response: URLResponse?, error: Error?, completion: @escaping APIResultClosure<T>) {
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let error = error {
                completion(.failure(MTError.networkError(error.localizedDescription)))
                return
            }
            
            if let tempData = data, let hydraError = try? self.decoder.decode(MTHydraError.self, from: tempData) {
                completion(.failure(MTError.mtError(hydraError.hydraDescription)))
                return
            }
            
            guard
                let response = response as? HTTPURLResponse,
                (200..<300) ~= response.statusCode
            else {
                completion(.failure(MTError.networkError("Something went wrong: Status code \((response as? HTTPURLResponse)?.statusCode ?? 0)")))
                return
            }
            
            guard let data = data else {
                completion(.failure(MTError.networkError("Data recevied was empty")))
                return
            }
            
            do {
                print(String(describing: T.self))
                let result = try self.decoder.decode(T.self, from: data)
                completion(.success(result))
            } catch let decoderError {
                let error = MTError.decodingError(decoderError.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    internal func bodyTypeRequest<T: Decodable>(request: URLRequest, completion: @escaping APIResultClosure<T>) -> MTAPIServiceTaskProtocol {
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            self.handleAPIOutput(data: data, response: response, error: error, completion: completion)
        }
        
        task.resume()
        return MTAPIServiceTask(sessionTask: task)
    }
    
    
}


public protocol MTAPIServiceTaskProtocol {
    var taskId: UUID { get }
    func cancel()
}

public final class MTAPIServiceTask: MTAPIServiceTaskProtocol {
    private let sessionTask: URLSessionDataTask
    
    public var taskId: UUID
    
    public init(sessionTask: URLSessionDataTask) {
        self.taskId = UUID()
        self.sessionTask = sessionTask
    }
    
    public func cancel() {
        sessionTask.cancel()
    }
}

public final class APIPlaceholderServiceTask: MTAPIServiceTaskProtocol {
    
    public var taskId: UUID = UUID()
    
    public func cancel() {
        // do nothing
    }
    
}

