//
//  ImageListViewPresenter.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 11.07.2023.
//

import Foundation

protocol ImageListViewPresenterProtocol: AnyObject {
    var imageListVC: ImageListViewControllerProtocol? { get set }
    var imageListTableAdapter: UITableViewAdapter? { get set }
    
    func updateRow(at indexPath: IndexPath)
    func didSelectRow(at indexPath: IndexPath)
    
    func getPhoto(withIndex index: Int) -> Photo
    func getFullSizeUrl(forIndex index: Int) -> String?
    func getCurrentPhotoCount() -> Int
    
    func processLike(for cell: ImagesListCell)
    func fetchNextPageIfShould(fromIndex index: Int?)
    
    func convertDate(_ date: String?) -> String
}

final class ImageListViewPresenter: ImageListViewPresenterProtocol {
    func didSelectRow(at indexPath: IndexPath) {
        imageListVC?.goToFullScreenView(senderIndexPath: indexPath)
    }
    
    func updateRow(at indexPath: IndexPath) {
        imageListVC?.updateRow(at: indexPath)
    }
    
    var imageListTableAdapter: UITableViewAdapter?
    var imageListVC: ImageListViewControllerProtocol?

    private var imageService = ImagesListService.shared
    
    private var photos: [Photo] = []
    
    private lazy var photoDateFormatter = ISO8601DateFormatter()
    private lazy var listDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    init() {

        self.imageListTableAdapter = ImageListTableViewAdaper(presenter: self)
        
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
    
    func fetchNextPageIfShould(fromIndex index: Int? = nil) {
        guard let index else {
            imageService.fetchPhotosNextPage()
            return
        }
        if photos.count - index == 3 {
            imageService.fetchPhotosNextPage()
        }
    }
    
    func convertDate(_ date: String?) -> String {
        var newDateString = ""
        if  let date,
            let photoDate = photoDateFormatter.date(from: date) {
            newDateString = listDateFormatter.string(from: photoDate)
        }
        return newDateString
    }
}

extension ImageListViewPresenter {
    
    func getCurrentPhotoCount() -> Int {
        return photos.count
    }
    
    func getFullSizeUrl(forIndex index: Int) -> String? {
        return photos[index].largeImageURL
    }
    
    func getPhoto(withIndex index: Int) -> Photo {
        return photos[index]
    }
    
    func processLike(for cell: ImagesListCell) {
        guard let photoIndex = cell.getIndexPath()?.row else { return }
        let photo = photos[photoIndex]
        
        imageService.changeLike(photoId: photo.id,
                                isLike: !photo.isLiked) {[weak self] (result: Result<Void, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success():
                self.photos = imageService.photos
//                guard let cell = self.tableView.cellForRow(at: IndexPath(row: photoIndex, section: 0)) as? ImagesListCell else { return }
                cell.likeButton.isSelected = self.photos[photoIndex].isLiked
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                    imageListVC?.showAlert(with: "Не получилось изменить лайк \(error.localizedDescription)")
            }
        }
    }
}
