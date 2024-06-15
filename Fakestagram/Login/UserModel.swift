//
//  This file is for educational purposes only. It may contain code snippets, examples, images, and explanations
//  intended to help understand concepts and improve programming skills.
//

import Foundation

class UserModel {
    let requestHandler: RequestHandlerProtocol = RequestHandler()
    
    var user: User? {
        didSet {
            Settings.user = user
        }
    }
}

enum UserModelError: Error, LocalizedError {
    case userNotFound, parsingError, fileError, badRequest, unexpectedResponse, invalidUser
    case badResponse(Int)
    
    var errorDescription: String? {
        switch self {
        case .fileError: return "Could not read from file"
        case .userNotFound: return "User not found"
        case .parsingError: return "Could not parse response"
        case .badRequest: return "The request could not be built."
        case .badResponse(let code): return "HTTP response \(code)"
        case .unexpectedResponse: return "Could not interpret response."
        case .invalidUser: return "Your user information is incomplete, please log in from our website to complete it. "
        }
    
    }
}

extension UserModel {
    func saveUser(from dto: UserDTO) throws {
        guard let id = dto.id, let name = dto.name, let email = dto.email, let username = dto.username else { throw UserModelError.invalidUser }
        user = User(id: id, name: name, username: username, email: email)
    }

    func findUser(email: String, completionHandler: @escaping (Error?) -> Void) {
        requestHandler.get(buildEndpoint(email: email)) { (result: Result<[UserDTO], Error>) in
            switch result {
            case .success(let users):
                guard let userDTO = users.first else {
                    completionHandler(UserModelError.userNotFound)
                    return
                }
                do {
                    try self.saveUser(from: userDTO)
                    completionHandler(nil)
                } catch {
                    completionHandler(error)
                }
            case .failure(let failure):
                completionHandler(failure)
            }
        }
    }
    
    func buildEndpoint(email: String) -> EndpointProtocol {
        let queries = [URLQueryItem(name: "email", value: email)]
        return UserBaseEndpoint(path: "/users", queries: queries)
    }
}
