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
    
    private var task: URLSessionTask?
    private var ongoingRequest = false
    
    private let session = URLSession.shared
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        
        var profileRequest = URLRequest.makeHttpRequest(path: "/me", httpMethod: "GET")
        profileRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        if ongoingRequest { return }
        self.task?.cancel()
        ongoingRequest = true
        
        let task = session.objectTask(for: profileRequest, completion: { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            assert(Thread.isMainThread)
            switch result {
            case .success(let profileResponse):
                let profile = Profile(username: profileResponse.username,
                                      firstName: profileResponse.firstName,
                                      lastName: profileResponse.lastName,
                                      bio: profileResponse.bio ?? "")
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                completion(.failure(error))
            }
            self.task = nil
            ongoingRequest = false
        })
        self.task = task
        task.resume()
    }
}
