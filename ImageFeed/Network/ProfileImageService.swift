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
    
    private var task: URLSessionTask?
    
    var userPic: UIImage?
    var userPicURL: String?
    var imageURL: URL?
    
    private let session = URLSession.shared
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        guard let token = OAuth2TokenStorage().token else { return }
        
        self.task?.cancel()
        
        var userpicRequest = URLRequest.makeHttpRequest(path: "/users/\(username)", httpMethod: "GET")
        userpicRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = session.objectTask(for: userpicRequest, completion: { (result: Result<UserResult, Error>) in
            
            switch result {
            case .success(let userpicResponse):
                completion(.success(userpicResponse.profileImage.large))
            case.failure(let error):
                completion(.failure(error))
            }
            
            self.task = nil
        })
        self.task = task
        task.resume()
    }
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
