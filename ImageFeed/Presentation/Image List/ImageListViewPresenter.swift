//
//  ImageListViewPresenter.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 11.07.2023.
//

import UIKit

protocol ImageListViewPresenterProtocol: AnyObject {
    var imageListVC: ImageListViewControllerProtocol? { get set }
    var imageListTableAdapter: UITableViewAdapterProtocol? { get set }
    
    func connectTable(_ table: UITableView)
    func updateRow(at indexPath: IndexPath)
    func didSelectRow(at indexPath: IndexPath)
    
    func getPhoto(withIndex index: Int) -> Photo
    func getFullSizeUrl(forIndex index: Int) -> String?
    func getCurrentPhotoCount() -> Int
    func convertDate(_ date: String?) -> String
    
    func processLike(for cell: ImagesListCell)
    func fetchNextPageIfShould(fromIndex index: Int?)
}

final class ImageListViewPresenter: ImageListViewPresenterProtocol {
    var imageListTableAdapter: UITableViewAdapterProtocol?
    var imageListVC: ImageListViewControllerProtocol?

    var imageService: ImagesListServiceProtocol!
    
    private var photos: [Photo] = []
    
    private lazy var photoDateFormatter = ISO8601DateFormatter()
    private lazy var listDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    init(adapter: UITableViewAdapterProtocol? = nil,
         service: ImagesListServiceProtocol = ImagesListService.shared) {
        self.imageService = service
        if adapter == nil {
            self.imageListTableAdapter = ImageListTableViewAdaper(presenter: self)
        }
        else {
            self.imageListTableAdapter = adapter
        }
        imageListTableAdapter?.presenter = self
        
        //MARK: - Notifications
        
        NotificationCenter.default.addObserver(
            forName: ImagesListService.ErrorNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self = self else { return }
                
                self.imageListVC?.showAlert(with: "Ошибка загрузки изображений")
            }
        
        NotificationCenter.default.addObserver(
            forName: ImagesListService.DidChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self = self else { return }
                
                let newCellsCount = imageService.photos.count - self.photos.count
                self.photos = imageService.photos
                imageListVC?.addCells(newCellsCount: newCellsCount)
            }
    }
}

extension ImageListViewPresenter {
    
    //MARK: - Date formatters
    
    func convertDate(_ date: String?) -> String {
        var newDateString = ""
        if  let date,
            let photoDate = photoDateFormatter.date(from: date) {
            newDateString = listDateFormatter.string(from: photoDate)
        }
        return newDateString
    }
    
    //MARK: - Photo array interaction
    
    func fetchNextPageIfShould(fromIndex index: Int? = nil) {
            imageService.fetchPhotosNextPage()
    }
    
    func getCurrentPhotoCount() -> Int {
        return photos.count
    }
    
    func getFullSizeUrl(forIndex index: Int) -> String? {
        return photos[index].largeImageURL
    }
    
    func getPhoto(withIndex index: Int) -> Photo {
        if index == photos.count % 10 - 3 {
            self.fetchNextPageIfShould(fromIndex: index)
        }
        return photos[index]
    }
    
    //MARK: - UITableView interaction
    
    func connectTable(_ table: UITableView) {
        imageListTableAdapter?.configTable(table)
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        imageListVC?.goToFullScreenView(senderIndexPath: indexPath)
    }
    
    func updateRow(at indexPath: IndexPath) {
        imageListVC?.updateRow(at: indexPath)
    }
    
    //MARK: - Like
    
    func processLike(for cell: ImagesListCell) {
        guard let photoIndex = cell.getIndexPath()?.row else { return }
        let photo = photos[photoIndex]
        
        imageService.changeLike(photoId: photo.id,
                                isLike: !photo.isLiked) {[weak self] (result: Result<Void, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success():
                self.photos = imageService.photos
                cell.changeLikeButtonStatus(liked: self.photos[photoIndex].isLiked)
            case .failure(let error):
                cell.changeLikeButtonStatus(liked: self.photos[photoIndex].isLiked)
                imageListVC?.showAlert(with: "Не получилось изменить лайк \(error.localizedDescription)")
            }
        }
    }
}
