//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 11.05.2023.
//

import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage! {
        didSet {
            guard isViewLoaded else {
                return
            }
            fullScreenImageView.image = image
        }
    }
    
    @IBOutlet private var fullScreenImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fullScreenImageView.contentMode = .center
        scrollView.minimumZoomScale = 0.1 // для картинок высокого разрешения
        scrollView.maximumZoomScale = 1.25 // для картинок высокого разрешения
        fullScreenImageView.image = image
        rescaleAndCenterImageInScrollView(image: image)
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
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        // TODO: отработать алерт ошибки
        guard let image = image else { assertionFailure("Error loading image"); return }
        let activityVC = UIActivityViewController(activityItems: [image],
                                                  applicationActivities: nil)
        present(activityVC, animated: true)
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
