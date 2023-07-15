//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 01.05.2023.
//

import UIKit
import Kingfisher

protocol ImageListCellDelegate: AnyObject {
    func processLike(for cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    weak var delegate: ImageListCellDelegate?
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    
    private var animationLayers = [CALayer]()
    private var gradient: CAGradientLayer!
    private var gradientAnimation: CABasicAnimation!
    private var usernameGradient: CAGradientLayer!
    
    var urlString = ""
    var displaySize = CGSize(width: 0, height: 0)
    
    static let reuseIdentifier = "ImagesListCell"
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
        urlString = ""
        gradient?.removeFromSuperlayer()
        gradient = nil
        
        urlString = ""
        displaySize = CGSize(width: 0, height: 0)
    }
    
    func loadImage(from url: URL, displaySize: CGSize) {
        self.isUserInteractionEnabled = false
        
        let placeholder = UIImage(named: "PhotoLoader") ?? UIImage()
        let resizer = ResizingImageProcessor(referenceSize: displaySize)
        cellImage.kf.setImage(with: url,
                              placeholder: placeholder.kf.resize(to: displaySize,for: .none), options: [.transition(.none), .processor(resizer)]) { [weak self] didLoad in
            guard let self else { return }
            switch didLoad {
            case .success(_):
                    self.removeGradient()
                    self.isUserInteractionEnabled = true
            case .failure(_):
                self.cellImage.image = UIImage(named: "PhotoLoader") ?? UIImage()
                self.cellImage.contentMode = .center
                self.removeGradient()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        restartAnimations()
    }
    
    func restartAnimations() {
        
        gradient?.add(gradientAnimation, forKey: "locationsChange")
           
        addGradient(ofSize: displaySize)
            guard let url = URL(string: urlString) else { return }
            loadImage(from: url, displaySize: displaySize)
    }
    
    func addGradient(ofSize size: CGSize) {
        gradient?.removeFromSuperlayer()
        gradient = configureGradient(ofSize: size)
        
        animationLayers.append(gradient)
        cellImage.layer.addSublayer(gradient)
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.5
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [-2, -1, 0]
        gradientChangeAnimation.toValue = [1, 2, 3]
        gradientAnimation = gradientChangeAnimation
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
    }
    
    func configureGradient(ofSize size: CGSize) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: size)
        gradient.locations = [-0.01, 0.25, 0.5]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor,
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.masksToBounds = true
        
        return gradient
    }
    
    func removeGradient() {
        UIView.transition(with: cellImage,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: {
            self.gradient.isHidden = true
                          },
                          completion: { _ in
            self.gradient.removeFromSuperlayer()
                          })
    }
    
    func changeLikeButtonStatus(liked: Bool) {
        likeButton.isSelected = liked
        
        UIView.animateKeyframes(withDuration: 0.5, delay: 0) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2, animations: {
                let scale = !liked ? 0.75 : 1.5
                self.likeButton.transform = CGAffineTransform(scaleX: scale, y: scale)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.2, animations: {
                self.likeButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        likeButton.isEnabled = true
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
        likeButton.isEnabled = false
        
        UIView.animateKeyframes(withDuration: 1, delay: 0, options: [.repeat]) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1) {
                self.likeButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.1) {
                self.likeButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.1) {
                self.likeButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.1) {
                self.likeButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }
        
        delegate?.processLike(for: self)
    }
}
