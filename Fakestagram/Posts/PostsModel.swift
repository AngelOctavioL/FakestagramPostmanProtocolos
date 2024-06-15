//
//  This file is for educational purposes only. It may contain code snippets, examples, images, and explanations
//  intended to help understand concepts and improve programming skills.
//

import Foundation

class PostsModel {
    var posts: [Post]?
    let requestHandler : RequestHandlerProtocol = RequestHandler()
    
    func post(for index: Int) -> Post? {
        posts?[index]
    }
    
    func getNumberOfPosts() -> Int {
        posts?.count ?? 0
    }
}

extension PostsModel {
    func getPosts(userID: Int, completionHandler: @escaping (Error?) -> Void) {
        requestHandler.get(buildEndpoint()) { (result: Result<[PostsDTO], Error>) in
            switch result {
            case .success(let PostsDTO):
                self.posts = PostsDTO.map{
                                        post in Post(title: post.title, body: post.body)
                                    }
            case .failure(let failure):
                completionHandler(failure)
            }
        }
    }
    
    func buildEndpoint() -> EndpointProtocol {
        let queries = [URLQueryItem(name: "_limit", value: "10"),
                       URLQueryItem(name: "_page", value: "1")
        ]
        return UserBaseEndpoint(path: "/posts", queries: queries)
    }
}
