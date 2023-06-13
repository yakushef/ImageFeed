//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 13.06.2023.
//

import UIKit

final class ProfileImageService {
    static let shared = ProfileImageService()
    var userPic: UIImage?
    
    private let urlSession = URLSession.shared
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        guard let token = OAuth2TokenStorage().token else { return }
        
        var userpicRequest = URLRequest.makeHttpRequest(path: "/users/\(username)", httpMethod: "GET")
        userpicRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let decoder = JSONDecoder()
        
        urlSession.data(for: userpicRequest) { (result: Result<Data, Error>) in
            let response = result.flatMap {  data -> Result<String, Error> in
                return Result {
                    let userpicResponse = try decoder.decode(UserResult.self, from: data)
                    print(userpicResponse)
                    return userpicResponse.profileImage.large
                }
            }
            completion(response)
        }
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
