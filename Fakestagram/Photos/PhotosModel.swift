//
//  This file is for educational purposes only. It may contain code snippets, examples, images, and explanations
//  intended to help understand concepts and improve programming skills.
//

import UIKit

class PhotosModel {
    var photos: [Photo]?
    let requestHandler : RequestHandlerProtocol = RequestHandler()
    
    func photo(for index: Int) -> Photo? {
        photos?[index]
    }
    
    func getNumberOfPhotos() -> Int {
        photos?.count ?? 0
    }
}

extension PhotosModel{
    func getPhoto() throws {
        guard let url = Bundle.main.url(forResource: "Photos", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { throw UserModelError.fileError }
        let photosDTOs = try [PhotoDTO](data: data)
        photos = photosDTOs.enumerated().map({ (index, photo) in
            if index == 0 {
                Photo(image: .dog1, caption: photo.title)
            } else if index % 2 == 0 {
                Photo(image: .images4, caption: photo.title)
            } else {
                Photo(image: .dog2Jpg, caption: photo.title)
            }
        })
    }
    
    func getPhotos(userID: Int, completionHandler: @escaping (Error?) -> Void) {
        requestHandler.get(buildEndpoint()) { (result: Result<[PhotoDTO], Error>) in
            switch result {
            case .success(let photosDTO):
                self.downloadPhotos(from: photosDTO, completion: { photos in
                    self.photos = photos
                    completionHandler(nil)
                })
            case .failure(let failure):
                completionHandler(failure)
            }
        }
    }
    
    private func downloadPhotos(from photosDTO: [PhotoDTO], completion: @escaping ([Photo]) -> Void) {
        DispatchQueue.global().async {
            var photos = [Photo]()
            let group = DispatchGroup()
            let semaphore = DispatchSemaphore(value: 3)
            for dto in photosDTO {
                guard let urlString = dto.url,
                      let url = URL(string: urlString) else { continue }
                let request = URLRequest(url: url)
                semaphore.wait()
                group.enter()
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let data, let image = UIImage(data: data, scale: 2) {
                        photos.append(Photo(image: image, caption: dto.title))
                    }
                    group.leave()
                    semaphore.signal()
                }
                task.resume()
            }
            group.wait()
            completion(photos)
        }
    }
    
    func buildEndpoint() -> EndpointProtocol {
        let queries = [URLQueryItem(name: "_limit", value: "20"),
                       URLQueryItem(name: "_page", value: "1")
        ]
        return UserBaseEndpoint(path: "/photos", queries: queries)
    }
}


