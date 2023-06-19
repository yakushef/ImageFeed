//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 13.06.2023.
//

import UIKit

final class ProfileImageService {
    
    static let DidChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    
    static let shared = ProfileImageService()
    var userPic: UIImage?
    var userPicURL: String?
    var imageURL: URL?
    
    private let session = URLSession.shared
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        guard let token = OAuth2TokenStorage().token else { return }
        
        var userpicRequest = URLRequest.makeHttpRequest(path: "/users/\(username)", httpMethod: "GET")
        userpicRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
//        let decoder = JSONDecoder()
        
        let task = session.objectTask(for: userpicRequest, completion: { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let userpicResponse):
//                if let url = URL(string: imageURLString) {
//                    self.imageURL = url
//                }
                completion(.success(userpicResponse.profileImage.large))
            case.failure(let error):
                completion(.failure(error))
            }
        })
        
        task.resume()
        
//        urlSession.data(for: userpicRequest) { (result: Result<Data, Error>) in
//            let response = result.flatMap {  data -> Result<String, Error> in
//                return Result {
//                    let userpicResponse = try decoder.decode(UserResult.self, from: data)
//                    print(userpicResponse)
//                    self.userPicURL = userpicResponse.profileImage.large
//                    if let url = URL(string: userpicResponse.profileImage.large) {
//                        self.imageURL = url
//                    }
//                    return userpicResponse.profileImage.large
//                }
//
//            }
//            completion(response)
//            NotificationCenter.default.post(name: ProfileImageService.DidChangeNotification,
//                                            object: self, userInfo: ["URL" : self.userPicURL])
//        }
    }
    
//    func fetchImage(fromURL imageURL: URL) {
//        let imageRequest = URLRequest(url: imageURL)
//
//        let imageTask = URLSession.shared.dataTask(with: imageRequest) { data, response, error in
//            guard let imageData = data else { return }
//
//            DispatchQueue.main.async  { [weak self] in
//                guard let self = self else { return }
//                self.userPic = UIImage(data: imageData) ?? UIImage()
//            }
//
//        }
//            imageTask.resume()
//    }
}

// MARK: - UserResult
struct UserResult: Codable {
    let profileImage: ProfileImage

    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

// MARK: - ProfileImage
struct ProfileImage: Codable {
    let small, medium, large: String
}
