//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 01.05.2023.
//

import UIKit
import Kingfisher

protocol ImageListCellDelegate {
    func processLike(photoIndex: Int, completion: @escaping () -> Void)
}

final class ImagesListCell: UITableViewCell {
    
    var delegate: ImageListCellDelegate?
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    
    static let reuseIdentifier = "ImagesListCell"
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
    }
    
    func getIndexPath() -> IndexPath? {
        guard let superView = self.superview as? UITableView else {
            print("superview is not a UITableView - getIndexPath")
            return nil
        }
        let indexPath = superView.indexPath(for: self)
        return indexPath
    }
    
    @IBAction func likeButtonTapped() {
//        print("INDEX:\(String(describing: getIndexPath()))")
        guard let indexPath = getIndexPath() else { return }
        likeButton.isSelected.toggle()
//        sender?.isEnabled = false
        delegate?.processLike(photoIndex: indexPath.row) {
            
        }
    }
    
}
