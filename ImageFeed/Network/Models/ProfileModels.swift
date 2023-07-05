//
//  ProfileModels.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 05.07.2023.
//

import Foundation

//MARK: - Profile Result

struct ProfileResult: Codable {
    let id: String
    let username, firstName: String
    let lastName: String?
    let bio: String?

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

//MARK: - Profile

struct Profile {
    
    let username: String
    let name: String
    let loginName: String
    let bio: String
    
    init(username: String, firstName: String, lastName: String?, bio: String?) {
        self.username = username
        self.name = firstName + ( " \(lastName ?? "")")
        self.loginName = "@" + username
        self.bio = bio ?? ""
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
