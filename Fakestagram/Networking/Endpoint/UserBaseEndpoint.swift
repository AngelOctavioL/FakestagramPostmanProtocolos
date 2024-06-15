//
//  UserBaseEndpoint.swift
//  Fakestagram
//
//  Created by Diplomado on 15/06/24.
//

import Foundation

struct UserBaseEndpoint: EndpointProtocol {
    let scheme: String = "https"
    var host: String = "jsonplaceholder.typicode.com"
    var queries: [URLQueryItem]?
    var path: String
    
    init(path: String, queries: [URLQueryItem]? = nil) {
        if let user = Settings.user?.id {
            if var queries {
                queries.append(URLQueryItem(name: "userId", value: "\(user)"))
                self.queries = queries
            } else {
                self.queries = [URLQueryItem(name: "userId", value: "\(user)")]
            }
        } else {
            self.queries = queries
        }
        self.path = path
    }
}

