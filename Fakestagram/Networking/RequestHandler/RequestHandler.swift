//
//  RequestHandler.swift
//  Fakestagram
//
//  Created by Diplomado on 15/06/24.
//

import Foundation

struct RequestHandler: RequestHandlerProtocol {
    var urlSession: URLSession
    
    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    func get<T: Decodable>(_ endpoint: EndpointProtocol, handler: @escaping (Result<T, Error>) -> Void) where T : Decodable {
        guard let request = endpoint.getRequest() else {
            handler(.failure(RequestHandlerError.badRequest))
            return
        }
        urlSession.dataTask(with: request) { data, response, error in
            if let error {
                handler(.failure(error))
            } else {
                guard let httpResponse = (response as? HTTPURLResponse) else {
                    handler(.failure(RequestHandlerError.unexpectedResponse))
                    return
                }
                guard httpResponse.statusCode == 200 else {
                    handler(.failure(RequestHandlerError.badResponse(httpResponse.statusCode, httpResponse.description)))
                    return
                }
                guard let data else {
                    handler(.failure(RequestHandlerError.emptyData))
                    return
                }
                do {
                    handler(.success(try T(data: data)))
                } catch {
                    handler(.failure(error))
                }
            }
        }.resume()
    }
}

