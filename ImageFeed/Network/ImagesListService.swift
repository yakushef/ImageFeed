//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 27.06.2023.
//

import Foundation

final class ImagesListService {
    static let shared = ImagesListService()
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    static let ErrorNotification = Notification.Name(rawValue: "ImagesListServiceError")
    
    private var photosTask: URLSessionTask? = nil
    private var likeTask: URLSessionTask? = nil
    
    private let session = URLSession.shared
    
    var photos: [Photo] = []
    
    private init(photosTask: URLSessionTask? = nil, likeTask: URLSessionTask? = nil) {
        self.photosTask = photosTask
        self.likeTask = likeTask
    }
    
    // MARK: - Fetch Photos Next Page
    
    func fetchPhotosNextPage() {
        guard let token = OAuth2TokenStorage().token else { return }
        
        self.photosTask?.cancel()
        
        let page = photos.count == 0 ? 0 : (photos.count / 10) + 1
        var photoRequest = URLRequest.makeHttpRequest(path: "/photos" + "?page=\(page)", httpMethod: "GET")
        photoRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = session.objectTask(for: photoRequest) { [weak self] (result: Result<PhotoResults, Error>) in
            guard let self = self else { return }
            assert(Thread.isMainThread)
            
            switch result {
            case .success(let photoResults):
                self.photos.append(contentsOf: photoResults.map { $0.convertToPhoto() })
                NotificationCenter.default.post(Notification(name: ImagesListService.DidChangeNotification))
            case .failure(let error):
                if error.localizedDescription != "cancelled" {
                    NotificationCenter.default.post(Notification(name: ImagesListService.ErrorNotification))
                }
            }
            self.photosTask = nil
        }
        self.photosTask = task
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
