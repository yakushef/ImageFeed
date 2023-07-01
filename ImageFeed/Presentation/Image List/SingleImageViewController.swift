//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 11.05.2023.
//

import UIKit
import ProgressHUD
import Kingfisher

final class SingleImageViewController: UIViewController {

    var imageURL: URL?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    @IBOutlet private var fullScreenImageView: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var shareButton: UIButton!
    
    private var doubleTapRecognizer: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIBlockingProgressHUD.show()
        
        shareButton.isEnabled = false
        
        fullScreenImageView.contentMode = .center
        scrollView.minimumZoomScale = 0.1 // для картинок высокого разрешения
        scrollView.maximumZoomScale = 1.25 // для картинок высокого разрешения
        
        doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapRecognizer.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapRecognizer)
        
        fullScreenImageView.kf.setImage(with: imageURL) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                let image = imageResult.image
                self.rescaleAndCenterImageInScrollView(image: image)
                UIBlockingProgressHUD.dismiss()
                self.shareButton.isEnabled = true
            case .failure(let error):
                // TODO: Handle Error
                assertionFailure(error.localizedDescription)
            }
        }
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        
        view.layoutIfNeeded()
        
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        
        let vScale = visibleRectSize.height / imageSize.height
        let hScale = visibleRectSize.width / imageSize.width
        let scale = max(hScale, vScale) // для тестовых картинок
        //let scale = min(scrollView.maximumZoomScale, max(minimumZoomScale, min(hScale, vScale))) //для картинок в высоком разрешении
        
        // для тестовых картинок в низком разрешении
        scrollView.minimumZoomScale = min(hScale, vScale)
        scrollView.maximumZoomScale = scale * 5
        
        scrollView.setZoomScale(scale, animated: false)
        
        view.layoutIfNeeded()
        
        var xOffset = scrollView.contentInset.left
        var yOffset = scrollView.contentInset.bottom
        
        if scrollView.frame.width < fullScreenImageView.frame.width {
            xOffset = (fullScreenImageView.frame.width - scrollView.frame.width) / 2
        } else {
            xOffset = (scrollView.frame.width - fullScreenImageView.frame.width) / 2
        }
        
        if scrollView.frame.height < fullScreenImageView.frame.height {
            yOffset = (fullScreenImageView.frame.height - scrollView.frame.height) / 2
        } else {
            yOffset = (scrollView.frame.height - fullScreenImageView.frame.height) / 2
        }
        
        scrollView.setContentOffset(CGPoint(x: xOffset, y: yOffset), animated: false)
    }
    
    private func centerImage() {
        var xOffset = scrollView.contentInset.left
        var yOffset = scrollView.contentInset.bottom
        
        if scrollView.frame.width < fullScreenImageView.frame.width {
            xOffset = 0
        } else {
            xOffset = (scrollView.frame.width - fullScreenImageView.frame.width) / 2
        }
        
        if scrollView.frame.height < fullScreenImageView.frame.height {
            yOffset = 0
        } else {
            yOffset = (scrollView.frame.height - fullScreenImageView.frame.height) / 2
        }
        
        scrollView.contentInset = UIEdgeInsets(top: yOffset,
                                               left: xOffset,
                                               bottom: yOffset,
                                               right: xOffset)
    }
    
    
    // MARK: - Navigation
    
    @IBAction private func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction private func didTapShareButton(_ sender: UIButton) {
        // TODO: отработать алерт ошибки
        guard let image = fullScreenImageView.image else { assertionFailure("Error loading image"); return }
        let activityVC = UIActivityViewController(activityItems: [image],
                                                  applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    @objc private func handleDoubleTap() {
        
        let visibleRectSize = scrollView.bounds.size
        let imageSize = fullScreenImageView.image?.size ?? visibleRectSize
        
        let vScale = visibleRectSize.height / imageSize.height
        let hScale = visibleRectSize.width / imageSize.width
        
        if scrollView.frame.width > fullScreenImageView.frame.width || scrollView.frame.height > fullScreenImageView.frame.height {

            let tapPoint = doubleTapRecognizer.location(in: fullScreenImageView)

            let zoomScale = scrollView.maximumZoomScale * 0.5
            
            let newSize = CGSize(width: fullScreenImageView.frame.width / zoomScale, height: fullScreenImageView.frame.height / zoomScale)
            let newOrigin = CGPoint(x: tapPoint.x - newSize.width / 2, y: tapPoint.y + newSize.height / 2)
            let newRect = CGRect(origin: newOrigin, size: newSize)
            
            scrollView.zoom(to: newRect, animated: true)
            
        } else {
            scrollView.setZoomScale(min(hScale, vScale), animated: true)
        }
    }
}

// MARK: - Zoom

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return fullScreenImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView,with view: UIView?, atScale scale: CGFloat) {
        centerImage()
    }
}
