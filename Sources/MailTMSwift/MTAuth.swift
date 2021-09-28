//
//  MTAuth.swift
//  
//
//  Created by Waseem Akram on 16/09/21.
//

import Foundation

public struct MTAuth: Codable, Equatable {

    public let address: String
    public let password: String

    public init(address: String, password: String) {
        self.address = address
        self.password = password
    }

}
