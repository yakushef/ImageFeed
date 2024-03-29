//
//  ImageFeedImagesListTests.swift
//  ImageFeedTests
//
//  Created by Aleksey Yakushev on 14.07.2023.
//

import XCTest
@testable import ImageFeed

//MARK: - Photo array stub

let photoArrayStub: [Photo] = [Photo(id: "testID1",
                                     size: CGSize(width: 33, height: 44),
                                     createdAt: "2016-05-03T11:00:28-04:00",
                                     welcomeDescription: nil,
                                     thumbImageURL: "testURL",
                                     largeImageURL: nil,
                                     isLiked: false),
                               Photo(id: "testID2",
                                     size: CGSize(width: 44, height: 55),
                                     createdAt: "invalid date format",
                                     welcomeDescription: "test descricption",
                                     thumbImageURL: "",
                                     largeImageURL: "",
                                     isLiked: true)]

//MARK: - Images List Service Spy

final class ImagesListServiceSpy: ImagesListServiceProtocol {
    var photos: [ImageFeed.Photo] = photoArrayStub
    
    var isChangeLikeCalled = false
    var isFetchPhotosCalled = false
    
    func fetchPhotosNextPage() {
        isFetchPhotosCalled = true
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        isChangeLikeCalled = true
    }
}

// MARK: Presenter Spy

final class ImageListViewPresenterSpy: ImageListViewPresenterProtocol {
    var photoCount: Int = 0
    
    var currentPage: Int = 0
    
    var imageListVC: ImageFeed.ImageListViewControllerProtocol?
    var imageListTableAdapter: ImageFeed.UITableViewAdapterProtocol?
    var photos: [Photo] = []
    var isLikeProcessed = false
    var isConnectTableCalled = false
    
    
    func checkIfNewPageIsNeeded(for index: Int) {
        
    }

    func connectTable(_ table: UITableView) {
        isConnectTableCalled = true
    }

    func updateRow(at indexPath: IndexPath) {
    
    }

    func didSelectRow(at indexPath: IndexPath) {

    }

    func getPhoto(withIndex index: Int) -> ImageFeed.Photo {
        return photos[index]
    }

    func getFullSizeUrl(forIndex index: Int) -> String? {
        return nil
    }

    func getCurrentPhotoCount() -> Int {
        return photos.count
    }

    func convertDate(_ date: String?) -> String {
        return ""
    }

    func processLike(for cell: ImageFeed.ImagesListCell) {
        isLikeProcessed = true
    }

    func fetchNextPageIfShould() {
        photos += photoArrayStub
    }
}

//MARK: - TESTS

final class ImageFeedImagesListTests: XCTestCase {
    func testLike() {
        // given
        let presenter = ImageListViewPresenterSpy()
        let adapter = ImageListTableViewAdaper(presenter: presenter)
        presenter.imageListTableAdapter = adapter
        let nib = UINib(nibName: "ImageListCell", bundle: nil)
        guard let testCell = nib.instantiate(withOwner: nil).first as? ImagesListCell else {
            XCTFail()
            return
        }
        testCell.delegate = adapter
        
        presenter.fetchNextPageIfShould()
        presenter.imageListTableAdapter?.configCell(for: testCell, with: IndexPath(row: 0, section: 0))
        
        // when
        testCell.likeButtonTapped()
        
        // then
        XCTAssertTrue(presenter.isLikeProcessed)
    }
    
    func testDateFormatter() {
        //given
        let presenter = ImageListViewPresenter()
        
        //when
        let correctDate = presenter.convertDate(photoArrayStub[0].createdAt)
        let incorrectDate = presenter.convertDate(photoArrayStub[1].createdAt)
        
        print(correctDate)
        print(incorrectDate)
        //then
        XCTAssertTrue(correctDate == "3 May 2016" || correctDate == "03 мая 2016" || correctDate == "May 3, 2016" || correctDate == "03 May 2016" || correctDate == "May 03, 2016")
        XCTAssertEqual(incorrectDate, "")
    }
    
    func testInitialTableSetup() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let imageListVC = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController else { XCTFail("VC casting problem"); return }
        let presenter = ImageListViewPresenterSpy()
        imageListVC.configure(presenter)
        
        //when
        _ = imageListVC.view
        
        //then
        XCTAssertTrue(presenter.isConnectTableCalled)
    }
    
    func testFetchNextPage() {
        //given
        let service = ImagesListServiceSpy()
        let presenter = ImageListViewPresenter(service: service)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let imageListVC = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController else { XCTFail("VC casting problem"); return }
        imageListVC.configure(presenter)
        
        //when
        _ = imageListVC.view
        
        //then
        XCTAssertTrue(service.isFetchPhotosCalled)
    }
}
