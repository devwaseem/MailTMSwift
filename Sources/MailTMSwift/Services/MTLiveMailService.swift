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
open class MTLiveMailService {

    public enum State {
        case opened, closed
    }

    private var eventSource: EventSource?

    public var statePublisher: AnyPublisher<MTLiveMailService.State, Never> {
        $state
            .receive(on: DispatchQueue.main, options: .init(qos: .utility))
            .eraseToAnyPublisher()
    }

    @Published private var state = State.closed

    public var messagePublisher: AnyPublisher<MTMessage, Never> {
        _messagePublisher
            .receive(on: DispatchQueue.main, options: .init(qos: .utility))
            .eraseToAnyPublisher()
    }
    
    public var accountPublisher: AnyPublisher<MTAccount, Never> {
        _accountPublisher
            .receive(on: DispatchQueue.main, options: .init(qos: .utility))
            .eraseToAnyPublisher()
    }

    private var _messagePublisher = PassthroughSubject<MTMessage, Never>()
    private var _accountPublisher = PassthroughSubject<MTAccount, Never>()

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
extension MTLiveMailService: EventHandler {

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
        print(messageEvent)
        guard
            eventType == "message",
            let data = messageEvent.data.data(using: .utf8)
        else {
            return
        }
        
        let dataType: HydraTypeResult.HydraTypeResult
        do {
            let result = try decoder.decode(HydraTypeResult.self, from: data)
            if let type = HydraTypeResult.HydraTypeResult(rawValue: result.type) {
                dataType = type
            } else {
                print("Unknown type: \(result.type)")
                return
            }
        } catch {
            print(error)
            return
        }
        
        switch dataType {
        case .account:
            do {
                let account = try decoder.decode(MTAccount.self, from: data)
                _accountPublisher.send(account)
                return
            } catch {
                print(error)
            }
        case .message:
            do {
                let message = try decoder.decode(MTMessage.self, from: data)
                _messagePublisher.send(message)
                return
            } catch let error {
                print(error)
            }
        }
    }

    public func onComment(comment: String) {
        // do nothing
    }

    public func onError(error: Error) {
        print(error)
    }

}
