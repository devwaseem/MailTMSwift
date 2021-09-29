//
//  MTDomain.swift
//  
//
//  Created by Waseem Akram on 15/09/21.
//

import Foundation

public struct MTDomain: Codable {

    public let id, domain: String
    public let isActive, isPrivate: Bool
    public let createdAt, updatedAt: Date

    public init(id: String, domain: String, isActive: Bool, isPrivate: Bool, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.domain = domain
        self.isActive = isActive
        self.isPrivate = isPrivate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        // swiftlint:disable redundant_string_enum_value
        case id = "id" // id key needed to differentiate id from @id field in JSON.
        case domain, isActive, isPrivate, createdAt, updatedAt
        // swiftlint:enable redundant_string_enum_value
    }
}

extension MTDomain: Hashable, Identifiable {}
