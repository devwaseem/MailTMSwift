//
//  MTJSONCoders.swift
//  
//
//  Created by Waseem Akram on 16/09/21.
//

import Foundation

final class MTJSONEncoder: JSONEncoder {
    
    override init() {
        super.init()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Config.dateFormat
        self.dateEncodingStrategy = .formatted(dateFormatter)
    }
    
}

final class MTJSONDecoder: JSONDecoder {
    
    override init() {
        super.init()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Config.dateFormat
        self.dateDecodingStrategy = .formatted(dateFormatter)
    }
    
}
