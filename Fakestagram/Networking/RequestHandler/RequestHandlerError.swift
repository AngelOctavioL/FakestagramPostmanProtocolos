//
//  RequestHandlerError.swift
//  Fakestagram
//
//  Created by Diplomado on 15/06/24.
//

import Foundation

enum RequestHandlerError: Error, LocalizedError {
    case badResponse(Int, String)
    case badRequest
    case emptyData
    case unexpectedResponse
    
    var errorDescription: String? {
        switch self {
        case .badRequest: return "Could not build request from provided URL"
        case let .badResponse(status, message): return "\(message) Code: \(status)"
        default: return ""
        }
    }
}

