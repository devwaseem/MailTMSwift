//
//  MTLiveMessagesService.swift
//  
//
//  Created by Waseem Akram on 16/09/21.
//

import Foundation
import Combine
import LDSwiftEventSource

/// A service class to listen for live create/update events for Accounts and Messages.
/// - Note: Internally it uses SSE events to listen for live events
@available(macOS 10.15, *)
@available(iOS 13.0, *)
@available(watchOS 6.0, *)
@available(tvOS 13.0, *)
@available(tvOS 13.0, *)
open class MTLiveMailService {
    
    /// State of connection
    ///  - Connected -> opened
    ///  - Disconnected -> closed
    public enum State {
        case opened, closed
    }

    private var eventSource: EventSource?
    
    /// A publisher that emits ``MTLiveMailService/State`` when the status of connection changes
    public var statePublisher: AnyPublisher<MTLiveMailService.State, Never> {
        $state
            .receive(on: DispatchQueue.main, options: .init(qos: .utility))
            .eraseToAnyPublisher()
    }

    @Published private var state = State.closed

    /// A publisher that emits ``MTMessage`` when the message is received/deleted/updated
    public var messagePublisher: AnyPublisher<MTMessage, Never> {
        _messagePublisher
            .receive(on: DispatchQueue.main, options: .init(qos: .utility))
            .eraseToAnyPublisher()
    }
    
    /// A publisher that emits ``MTAccount`` when account is updated.
    public var accountPublisher: AnyPublisher<MTAccount, Never> {
        _accountPublisher
            .receive(on: DispatchQueue.main, options: .init(qos: .utility))
            .eraseToAnyPublisher()
    }

    private var _messagePublisher = PassthroughSubject<MTMessage, Never>()
    private var _accountPublisher = PassthroughSubject<MTAccount, Never>()

    private let decoder = MTJSONDecoder()

    private let token: String
    private let accountId: String
    
    /// Retry the listener automatically when the connection goes off
    /// - Note: Default is false
    let autoRetry = false
    
    /// Create a new instance
    /// - Parameters:
    ///   - token: account JWT token
    ///   - accountId: account Id
    public init(token: String, accountId: String) {
        self.token = token
        self.accountId = accountId
    }

    deinit {
        self._messagePublisher.send(completion: .finished)
    }
    
    /// Start listening for live mail events by connecting to Mail.tm SSE events
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
    
    /// Stop listening for live mail events
    public func stop() {
        eventSource?.stop()
    }

    /// Restart the connection for listening live mail events
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
                print("[MTLiveMailService] Unknown type: \(result.type)")
                return
            }
        } catch {
            print("[MTLiveMailService], Error: ", error)
            return
        }
        
        switch dataType {
        case .account:
            do {
                let account = try decoder.decode(MTAccount.self, from: data)
                _accountPublisher.send(account)
                return
            } catch {
                print("[MTLiveMailService], Error: ", error)
            }
        case .message:
            do {
                let message = try decoder.decode(MTMessage.self, from: data)
                _messagePublisher.send(message)
                return
            } catch {
                print("[MTLiveMailService], Error: ", error)
            }
        }
    }

    public func onComment(comment: String) {
        // do nothing
    }

    public func onError(error: Error) {
        print("[MTLiveMailService], Error: ", error)
    }

}
