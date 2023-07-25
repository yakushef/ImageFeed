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
    func checkIfnewPageIsNeeded(for index: Int)
}

final class ImagesListCell: UITableViewCell {
    
    weak var delegate: ImageListCellDelegate?
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    
    private var animationLayers = [CALayer]()
    private var gradient: CAGradientLayer!
    private var gradientAnimation: CABasicAnimation!
    
    var urlString = ""
    var displaySize = CGSize(width: 0, height: 0)
    var index = 0
    
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        restartAnimations()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil

        gradient?.removeFromSuperlayer()
        gradient = nil
        
        urlString = ""
        displaySize = CGSize(width: 0, height: 0)
    }
    
    // MARK: - Load Image
    func loadImage(from url: URL, displaySize: CGSize) {
        self.isUserInteractionEnabled = false
        
        let placeholder = UIImage(named: "PhotoLoader") ?? UIImage()
        
        var scaledPlaceholder = UIImage()
        
        UIGraphicsBeginImageContextWithOptions(displaySize, false, 0.0)
        if let context = UIGraphicsGetCurrentContext(),
           displaySize.height >= placeholder.size.height,
           displaySize.width >= placeholder.size.width {
            
            context.setFillColor(UIColor.clear.cgColor)
            context.fill(CGRect(origin: .zero, size: displaySize))
            
            let placeholderOrigin = CGPoint(x: (displaySize.width - placeholder.size.width) / 2,
                                            y: (displaySize.height - placeholder.size.height) / 2)
            placeholder.draw(in: CGRect(origin: placeholderOrigin, size: placeholder.size))
            
            scaledPlaceholder = UIGraphicsGetImageFromCurrentImageContext() ?? placeholder
        } else {
            UIImage().draw(in: CGRect(origin: CGPoint.zero, size: displaySize))
            scaledPlaceholder = UIGraphicsGetImageFromCurrentImageContext() ?? placeholder
        }
        UIGraphicsEndImageContext()
        
        cellImage.image = scaledPlaceholder
        cellImage.contentMode = .center

        cellImage.kf.setImage(with: url,
                              placeholder: nil, options: [.transition(.fade(0)), .keepCurrentImageWhileLoading]) { [weak self] didLoad in
            guard let self else { return }
            switch didLoad {
            case .success(_):
                self.removeGradient(duration: 0.2)
                    self.isUserInteractionEnabled = true
            case .failure(_):
                self.removeGradient(duration: 0.5)
            }
        }
    }
    
    // MARK: - Gradients
    
    func restartAnimations() {
        gradient?.add(gradientAnimation, forKey: "locationsChange")
           
        addGradient(ofSize: displaySize)
        guard let url = URL(string: urlString) else { return }
        loadImage(from: url, displaySize: displaySize)
    }
    
    func addGradient(ofSize size: CGSize) {
        gradient?.removeFromSuperlayer()
        gradient = configureGradient(ofSize: CGSize(width: size.width * 1.1, height: size.height * 1.1))
        
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
    
    func removeGradient(duration: CFTimeInterval = 0.0) {
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 1.0
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = duration

        gradient.add(fadeAnimation, forKey: "opacity")
        gradient.opacity = 0.0
    }
    
    //MARK: - Cell methods
    
    func changeLikeButtonStatus(liked: Bool) {
        likeButton.isSelected = liked
        likeButton.accessibilityIdentifier = liked ? "likeButtonActive" : "likeButtonInactive"
        
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
