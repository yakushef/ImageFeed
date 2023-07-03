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
    
    func convertToPhoto() -> Photo {
        Photo(id: self.id,
              size: CGSize(width: self.width,
                           height: self.height),
              createdAt: self.createdAt,
              welcomeDescription: self.description,
              thumbImageURL: self.urls.small,
              largeImageURL: self.urls.full,
              isLiked: self.likedByUser)
    }
}

struct LikeResult: Decodable {
    let photo: PhotoResult
}

typealias PhotoResults = [PhotoResult]

// MARK: - PhotoURLs
struct PhotoURLs: Decodable {
    let raw, full, regular: String?
    let thumb, small: String
}

// MARK: - Photo for ImageList

struct Photo {
    let id: String
    let size: CGSize
    let aspectRatio: Double
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String?
    let isLiked: Bool
    
    init(id: String, size: CGSize, createdAt: String?, welcomeDescription: String?, thumbImageURL: String, largeImageURL: String?, isLiked: Bool) {
        self.id = id
        self.size = size
        self.aspectRatio = size.width / size.height
        
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: createdAt ?? "")
        
        self.createdAt = date
        self.welcomeDescription = welcomeDescription
        self.thumbImageURL = thumbImageURL
        self.largeImageURL = largeImageURL
        self.isLiked = isLiked
    }
}

final class ImagesListService {
    static let shared = ImagesListService()
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    static let ErrorNotification = Notification.Name(rawValue: "ImagesListServiceError")
    
    private var task: URLSessionTask? = nil
    private var likeTask: URLSessionTask? = nil
    
    private let session = URLSession.shared
    
    var photos: [Photo] = []
    
    // MARK: - Fetch Photos Next Page
    
    func fetchPhotosNextPage() {
        guard let token = OAuth2TokenStorage().token else { return }
        
        let page = (photos.count / 10) + 1
        var photoRequest = URLRequest.makeHttpRequest(path: "/photos" + "?page=\(page)", httpMethod: "GET")
        photoRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = session.objectTask(for: photoRequest) { [weak self] (result: Result<PhotoResults, Error>) in
            guard let self = self else { return }
            assert(Thread.isMainThread)
            
            switch result {
            case .success(let photoResults):
                for photoResult in photoResults {
                    self.photos.append(photoResult.convertToPhoto())
                }
                NotificationCenter.default.post(Notification(name: ImagesListService.DidChangeNotification))
            case .failure(_):
                NotificationCenter.default.post(Notification(name: ImagesListService.ErrorNotification))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    //MARK: - Change Like
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = OAuth2TokenStorage().token else { return }
        
        self.likeTask?.cancel()
        
        let requestPath = "/photos/\(photoId)/like"
        let method = isLike ? "POST" : "DELETE"
        
        var likeRequest =  URLRequest.makeHttpRequest(path: requestPath, httpMethod: method)
        likeRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = session.objectTask(for: likeRequest, completion: { [weak self] (result: Result<LikeResult, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let likeResult):
                let newPhoto = likeResult.photo.convertToPhoto()
                
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    self.photos[index] = newPhoto
                }
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
            self.likeTask = nil
        })
        self.likeTask = task
        task.resume()
    }
}
