//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Aleksey Yakushev on 28.06.2023.
//

import XCTest
@testable import ImageFeed

final class ImagesListServiceTests: XCTestCase {
    var pages = 0
    
    func testFetchPhotos() {
            
        let service = ImagesListService.shared
            
            let expectation = self.expectation(description: "Wait for Notification")
            NotificationCenter.default.addObserver(
                forName: ImagesListService.DidChangeNotification,
                object: nil,
                queue: .main) { [weak self] _ in
                    guard let self = self else {
                        return
                    }
                    self.pages += 1
                    if self.pages == 1 { expectation.fulfill() } else { return }
                }


        service.fetchPhotosNextPage()
            self.wait(for: [expectation], timeout: 10)
            
            XCTAssertEqual(service.photos.count, 10)
    }
}
