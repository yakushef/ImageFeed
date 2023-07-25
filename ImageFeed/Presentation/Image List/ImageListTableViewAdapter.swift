//
//  ImageListTableViewAdapter.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 12.07.2023.
//

import UIKit
import Kingfisher

protocol UITableViewAdapterProtocol: AnyObject {
    var presenter: ImageListViewPresenterProtocol! { get set }
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath)
    func configTable(_ table: UITableView)
}

final class ImageListTableViewAdaper: UITableViewAdapterProtocol & NSObject {
    var presenter: ImageListViewPresenterProtocol!
    
    init(presenter: ImageListViewPresenterProtocol) {
        self.presenter = presenter
    }

    //MARK: Cell Congiguration
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let index = indexPath.row
        cell.index = index
        let photo = presenter.getPhoto(withIndex: index)
        
        cell.delegate = self
        
        cell.accessibilityIdentifier = "Cell \(index)"
        
        cell.selectionStyle = .none
        
        cell.dateLabel.text = presenter.convertDate(photo.createdAt)

        let isLiked = photo.isLiked
        cell.likeButton.isSelected = isLiked
        cell.likeButton.setImage(UIImage(named: "likeButtonActive"), for: .selected)
        cell.likeButton.setImage(UIImage(named: "likeButtonInactive"), for: .normal)
        cell.likeButton.accessibilityIdentifier = isLiked ? "likeButtonActive" : "likeButtonInactive"
        
        let scaleFactor = photo.size.width / cell.cellImage.frame.size.width
        let displaySize: CGSize = CGSize(width: photo.size.width / scaleFactor, height: photo.size.height / scaleFactor)
        
        cell.displaySize = displaySize
        cell.urlString = photo.thumbImageURL

        cell.restartAnimations()
    }
    
    // MARK: - Table View
    
    func configTable(_ table: UITableView) {
        table.dataSource = self
        table.delegate = self
    }
}

extension ImageListTableViewAdaper: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.getCurrentPhotoCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier,
                                                 for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
}

extension ImageListTableViewAdaper: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if  let visibleCells = tableView.indexPathsForVisibleRows,
            visibleCells.contains(indexPath) {
            presenter.checkIfNewPageIsNeeded(for: indexPath.row)
        }
        guard let cell = cell as? ImagesListCell else { return }
        cell.restartAnimations()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectRow(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Cell Delegate

extension ImageListTableViewAdaper: ImageListCellDelegate {
    func processLike(for cell: ImagesListCell) {
        presenter?.processLike(for: cell)
    }
    
    func checkIfnewPageIsNeeded(for index: Int) {
        presenter.checkIfNewPageIsNeeded(for: index)
    }
}
