//
//  HydraWrapper.swift
//  
//
//  Created by Waseem Akram on 15/09/21.
//

import Foundation

struct HydraWrapper<T>: Codable where T : Codable {
    let context, id, type: String
    let result: T
    let hydraTotalItems: Int

    enum CodingKeys: String, CodingKey {
        case context = "@context"
        case id = "@id"
        case type = "@type"
        case result = "hydra:member"
        case hydraTotalItems = "hydra:totalItems"
    }
}


//randommmmm@uniromax.com
//helo12312312

