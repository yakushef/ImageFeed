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
    
    @IBOutlet var fullScreenImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fullScreenImageView.image = image
    }
    


    // MARK: - Navigation


}
