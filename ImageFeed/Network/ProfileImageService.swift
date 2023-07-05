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
    
    var userPicURL: String?
    var imageURL: URL?
    
    private let session = URLSession.shared
    
    private init(task: URLSessionTask? = nil, userPicURL: String? = nil, imageURL: URL? = nil) {
        self.task = task
        self.userPicURL = userPicURL
        self.imageURL = imageURL
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        guard let token = OAuth2TokenStorage().token else { return }
        
        self.task?.cancel()
        
        var userpicRequest = URLRequest.makeHttpRequest(path: "/users/\(username)", httpMethod: "GET")
        userpicRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = session.objectTask(for: userpicRequest, completion: { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let userpicResponse):
                NotificationCenter.default.post(Notification(name: ProfileImageService.DidChangeNotification))
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
