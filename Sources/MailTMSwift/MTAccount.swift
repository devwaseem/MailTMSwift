//
//  MTAccount.swift
//  
//
//  Created by Waseem Akram on 15/09/21.
//

import Foundation

public struct MTAccount: Codable {

    public let id, address: String
    public let quotaLimit, quotaUsed: Int
    public let isDisabled, isDeleted: Bool
    public let createdAt, updatedAt: Date
    
    public var isQuotaLimitReached: Bool {
        quotaUsed >= quotaLimit
    }
    
    public var quotaUsedPercetage: Float {
        min(Float(quotaUsed)/Float(quotaLimit), 1)
    }
    
    public init(id: String, address: String, quotaLimit: Int, quotaUsed: Int, isDisabled: Bool, isDeleted: Bool, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.address = address
        self.quotaLimit = quotaLimit
        self.quotaUsed = quotaUsed
        self.isDisabled = isDisabled
        self.isDeleted = isDeleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case quotaLimit = "quota"
        case quotaUsed = "used"
        case id, isDisabled, isDeleted, createdAt, updatedAt, address
    }
    
}

