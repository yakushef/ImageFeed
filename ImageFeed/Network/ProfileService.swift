//
//  ProfileService.swift.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 12.06.2023.
//

import Foundation

import WebKit

final class ProfileService {
    
    static let shared = ProfileService()
    
    var profile: Profile?
    private var task: URLSessionTask?
    private let session = URLSession.shared
    
    private init(profile: Profile? = nil, task: URLSessionTask? = nil) {
        self.profile = profile
        self.task = task
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        
        var profileRequest = URLRequest.makeHttpRequest(path: "/me", httpMethod: "GET")
        profileRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        self.task?.cancel()
        
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
        })
        self.task = task
        task.resume()
    }
}

// MARK: - Logout

extension ProfileService {
    func clean() {
        profile = nil
        
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
           records.forEach { record in
              WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
           }
        }
     }
}
