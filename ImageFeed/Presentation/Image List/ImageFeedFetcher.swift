//
//  feedFetcher.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 11.07.2023.
//

import Foundation

protocol ImageServiceOperatorProtocol {
    func fetchNextPage()
    func processLike()
}

final class ImageImageServiceOperator: ImageServiceOperatorProtocol {
    
    private let imageService = ImagesListService.shared
    
    func fetchNextPage() {
        
    }
    
    func processLike() {
        
    }
}
