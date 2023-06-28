//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Aleksey Yakushev on 28.06.2023.
//

import XCTest
@testable import ImageFeed

final class ImagesListServiceTests: XCTestCase {
    func testFetchPhotos() {
            let service = ImagesListService()
            
            let expectation = self.expectation(description: "Wait for Notification")
            NotificationCenter.default.addObserver(
                forName: ImagesListService.DidChangeNotification,
                object: nil,
                queue: .main) { _ in
                    expectation.fulfill()
                }
            
            service.fetchPhotosNextPage()
            self.wait(for: [expectation], timeout: 10)
            
            XCTAssertEqual(service.photos.count, 10)
    }
}
