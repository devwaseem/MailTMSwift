//
//  MTLiveMessagesService.swift
//  
//
//  Created by Waseem Akram on 16/09/21.
//

import Foundation
import Combine
import LDSwiftEventSource

@available(macOS 10.15, *)
@available(iOS 13.0, *)
@available(watchOS 6.0, *)
@available(tvOS 13.0, *)
@available(tvOS 13.0, *)
open class MTLiveMessagesService {

    public typealias ResultType = Result<MTMessage, MTError>

    public enum State {
        case opened, closed
    }

    private var eventSource: EventSource?

    public var statePublisher: AnyPublisher<MTLiveMessagesService.State, Never> {
        $state.eraseToAnyPublisher()
    }

    @Published private var state = State.closed

    public var messagePublisher: AnyPublisher<ResultType, Never> {
        _messagePublisher.eraseToAnyPublisher()
    }

    private var _messagePublisher = PassthroughSubject<ResultType, Never>()

    let decoder = MTJSONDecoder()

    let token: String
    let accountId: String

    let autoRetry = false

    public init(token: String, accountId: String) {
        self.token = token
        self.accountId = accountId
    }

    deinit {
        self._messagePublisher.send(completion: .finished)
    }

    public func start() {
        guard let sseURL = URL(string: "\(Config.sseURL)?topic=/accounts/\(accountId)") else {
            fatalError("Invalid SSE URL")
        }
        var config = EventSource.Config(handler: self, url: sseURL)
        config.headers = ["authorization": "Bearer \(token)"]
        let eventSource = EventSource(config: config)
        self.eventSource = eventSource
        eventSource.start()
    }

    public func stop() {
        eventSource?.stop()
    }

    public func restart() {
        eventSource?.stop()
        start()
    }

}

@available(macOS 10.15, *)
@available(iOS 13.0, *)
@available(watchOS 6.0, *)
@available(tvOS 13.0, *)
extension MTLiveMessagesService: EventHandler {

    public func onOpened() {
        state = .opened
    }

    public func onClosed() {
        state = .closed
        if autoRetry {
            restart()
        }
    }

    public func onMessage(eventType: String, messageEvent: MessageEvent) {
        guard
            eventType == "message",
            let data = messageEvent.data.data(using: .utf8)
        else {
            return
        }
        
        // if MTAccount received, ignore the output
        // swiftlint:disable unused_optional_binding
        if let _ = try? decoder.decode(MTAccount.self, from: data) {
            return
        }
        // swiftlint:enable unused_optional_binding
        
        do {
            let message = try decoder.decode(MTMessage.self, from: data)
            _messagePublisher.send(.success(message))
        } catch let error {
            _messagePublisher.send(.failure(.decodingError(error.localizedDescription)))
        }
    }

    public func onComment(comment: String) {
        // do nothing
    }

    public func onError(error: Error) {
        _messagePublisher.send(.failure(.networkError(error.localizedDescription)))
    }

}
