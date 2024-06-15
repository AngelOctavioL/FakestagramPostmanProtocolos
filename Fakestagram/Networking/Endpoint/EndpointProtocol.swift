//
//  EndpointProtocol.swift
//  Fakestagram
//
//  Created by Diplomado on 15/06/24.
//

import Foundation

protocol EndpointProtocol {
    var path: String { get }
    var scheme: String { get }
    var host: String { get }
    var queries: [URLQueryItem]? { get }
    func getRequest() -> URLRequest?
}

extension EndpointProtocol {
    func getRequest() -> URLRequest? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queries
        guard let url = components.url else { return nil }
        return URLRequest(url: url)
    }
}

