//
//  MTError.swift
//  
//
//  Created by Waseem Akram on 15/09/21.
//

import Foundation

/// Error type for MailTMSwift
public enum MTError: Error, LocalizedError {
    /// Returns error related to network
    case networkError(String)
    /// Returns error related to [Mail.tm](https://mail.tm) API error
    case mtError(String)
    /// Returns error related to JSON Encoding
    case encodingError(String)
    /// Returns error related to JSON Decoding
    case decodingError(String)

    public var errorDescription: String? {
        switch self {
        case .mtError(let error):
            return error
        case .networkError(let error):
            return error
        case .decodingError(let error):
            return error
        case .encodingError(let error):
            return error
        }
    }
}
