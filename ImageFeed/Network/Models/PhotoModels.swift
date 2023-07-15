//
//  Models.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 05.07.2023.
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

typealias PhotoResults = [PhotoResult]

//MARK: - Like Result

struct LikeResult: Decodable {
    let photo: PhotoResult
}

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
    let createdAt: String?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String?
    let isLiked: Bool
    
    init(id: String, size: CGSize, createdAt: String?, welcomeDescription: String?, thumbImageURL: String, largeImageURL: String?, isLiked: Bool) {
        self.id = id
        self.size = size
        self.aspectRatio = size.height / size.width
        self.createdAt = createdAt
        self.welcomeDescription = welcomeDescription
        self.thumbImageURL = thumbImageURL
        self.largeImageURL = largeImageURL
        self.isLiked = isLiked
    }
}
