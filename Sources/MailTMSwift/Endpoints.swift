//
//  Endpoints.swift
//  
//
//  Created by Waseem Akram on 15/09/21.
//

import Foundation

enum Endpoints {
            
    static var token = withBaseUrl(path: "token")
    static var myAccount = withBaseUrl(path: "me")
    
    static var account = withBaseUrl(path: "accounts")
    static var accountFromId = { (id: String) in withBaseUrl(path: "accounts/\(id)") }
    
    static var domains = withBaseUrl(path: "domains")
    static var domainFromId = { (id: String) in withBaseUrl(path: "domains/\(id)") }
    
    static var messages = withBaseUrl(path: "messages")
    static var messagesFromId = { (id: String) in withBaseUrl(path: "messages/\(id)") }
    
    static var sourcesFromId = { (id: String) in withBaseUrl(path: "sources/\(id)") }
    
    private static func withBaseUrl(path: String) -> String {
        return Config.baseURL + "/" + path
    }
    
}
