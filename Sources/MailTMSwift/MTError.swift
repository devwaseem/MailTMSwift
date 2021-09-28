//
//  File.swift
//  
//
//  Created by Waseem Akram on 15/09/21.
//

import Foundation

public enum MTError: Error, LocalizedError {
    case networkError(String)
    case mtError(String)
    case encodingError(String)
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

