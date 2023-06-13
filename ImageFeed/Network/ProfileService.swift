//
//  ProfileService.swift.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 12.06.2023.
//

import Foundation

struct ProfileResult: Codable {
    let id: String
    let username, firstName, lastName: String
    let bio: String?

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

//struct Links: Codable {
//    let linksSelf, html, photos, likes: String
//    let portfolio: String
//
//    enum CodingKeys: String, CodingKey {
//        case linksSelf = "self"
//        case html, photos, likes, portfolio
//    }
//}

struct Profile {
    
    let username: String
    let name: String
    let loginName: String
    let bio: String
    
    init(username: String, firstName: String, lastName: String, bio: String = "") {
        self.username = username
        self.name = firstName + " " + lastName
        self.loginName = "@" + username
        self.bio = bio
    }
}

final class ProfileService {
    
    static let shared = ProfileService()
    var profile: Profile?
    
    private let urlSession = URLSession.shared
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        var profileRequest = URLRequest.makeHttpRequest(path: "/me", httpMethod: "GET")
        profileRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let decoder = JSONDecoder()
        
        urlSession.data(for: profileRequest) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<Profile, Error> in
                return Result {
                        let profileResponse = try decoder.decode(ProfileResult.self, from: data)
                        return Profile(username: profileResponse.username, firstName: profileResponse.firstName, lastName: profileResponse.lastName, bio: profileResponse.bio ?? "")
                }
            }
            completion(response)
        }
    }
}
