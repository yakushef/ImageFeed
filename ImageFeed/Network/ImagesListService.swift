//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 27.06.2023.
//

import Foundation

// MARK: - PhotoResult
struct PhotoResult: Decodable {
    let id: String
    let createdAt: String
    let width, height, likes: Int
    let likedByUser: Bool
    let description: String?
    let urls: PhotoURLs

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width, height, likes
        case likedByUser = "liked_by_user"
        case description, urls
    }
}

typealias PhotoResults = [PhotoResult]

// MARK: - PhotoURLs
struct PhotoURLs: Decodable {
    let raw, full, regular, small: String?
    let thumb: String
}

// MARK: - Photo for ImageList

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: String?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String?
    let isLiked: Bool
}

final class ImagesListService {
    static let shared = ImagesListService()
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private var task: URLSessionTask? = nil
    
    private let session = URLSession.shared
    
    var photos: [Photo] = []
    
    // MARK: - Fetch Photos Next Page
    
    func fetchPhotosNextPage() {
        guard let token = OAuth2TokenStorage().token else { return }
        
        print("PAGE: \((photos.count / 10) + 1)")
        
        var photoRequest = URLRequest.makeHttpRequest(path: "/photos", httpMethod: "GET")
        photoRequest.setValue("\((photos.count / 10) + 1)", forHTTPHeaderField: "page")
        photoRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        self.task?.cancel()
        
        let task = session.objectTask(for: photoRequest) { [weak self] (result: Result<PhotoResults, Error>) in
            guard let self = self else { return }
            assert(Thread.isMainThread)
            
            switch result {
            case .success(let photoResults):
                for photoResult in photoResults {
                    let photo = Photo(id: photoResult.id,
                                      size: CGSize(width: photoResult.width,
                                                   height: photoResult.height),
                                      createdAt: photoResult.createdAt,
                                      welcomeDescription: photoResult.description,
                                      thumbImageURL: photoResult.urls.thumb,
                                      largeImageURL: photoResult.urls.full,
                                      isLiked: photoResult.likedByUser)
                    self.photos.append(photo)
                }
                NotificationCenter.default.post(Notification(name: ImagesListService.DidChangeNotification))
            case .failure(let error):
                // TODO: Handle Error
                assertionFailure(error.localizedDescription)
            }
            
            self.task = nil
        }
        self.task = task
        task.resume()
    }
}
