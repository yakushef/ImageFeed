//
//  ImageListTableViewAdapter.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 12.07.2023.
//

import UIKit
import Kingfisher

protocol UITableViewAdapter: AnyObject {
    var presenter: ImageListViewPresenterProtocol! { get set }
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath)
    func configTable(_ table: UITableView)
}

final class ImageListTableViewAdaper: UITableViewAdapter & NSObject {
    var presenter: ImageListViewPresenterProtocol!
    
    init(presenter: ImageListViewPresenterProtocol) {
        self.presenter = presenter
    }
    
    func configTable(_ table: UITableView) {
        table.dataSource = self
        table.delegate = self
    }
    
    //MARK: Cell Congiguration
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let index = indexPath.row
        let photo = presenter.getPhoto(withIndex: index)
        presenter.fetchNextPageIfShould(fromIndex: index)
        
        cell.delegate = self
        
        cell.selectionStyle = .none
        
        cell.dateLabel.text = presenter.convertDate(photo.createdAt)

        let isLiked = photo.isLiked
        cell.likeButton.isSelected = isLiked
        cell.likeButton.setImage(UIImage(named: "likeButtonActive"), for: .selected)
        cell.likeButton.setImage(UIImage(named: "likeButtonInactive"), for: .normal)
        
        guard let imageURL = URL(string: photo.thumbImageURL)
        else { return }
        
        cell.cellImage.kf.setImage(with: imageURL, placeholder: UIImage(named: "PhotoLoaderFull")) { [weak self] didLoad in
            guard let self = self else { return }
            switch didLoad {
            case .success(_):
                self.presenter.updateRow(at: indexPath)
            case .failure(_):
                return
            }
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectRow(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ImageListTableViewAdaper: ImageListCellDelegate {
    func processLike(for cell: ImagesListCell) {
        presenter?.processLike(for: cell)
    }
}
