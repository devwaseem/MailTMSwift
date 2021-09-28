//
//  File.swift
//  
//
//  Created by Waseem Akram on 22/09/21.
//

import Foundation

// MARK: - MTHydraError
struct MTHydraError: Codable {
    let context, type, hydraTitle, hydraDescription: String
    let violations: [MTHydraViolation]?

    enum CodingKeys: String, CodingKey {
        case context = "@context"
        case type = "@type"
        case hydraTitle = "hydra:title"
        case hydraDescription = "hydra:description"
        case violations
    }
}

// MARK: - Violation
struct MTHydraViolation: Codable {
    let propertyPath, message, code: String?
}
