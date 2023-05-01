//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 01.05.2023.
//

import UIKit

class GradientImageView: UIImageView {
    
    let gradientLayer = CAGradientLayer()
    
    override func awakeFromNib() {
        // add UIColor extension
        let gradientColor: CGColor = UIColor(named: "Gradient")!.cgColor
        
        //let gradientColor = CGColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0.2)
        
        // Configure the gradient layer
        gradientLayer.colors = [gradientColor, UIColor.clear.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        
        // Add the gradient layer to the view's layer
        layer.addSublayer(gradientLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        //gradientLayer.frame = bounds
        gradientLayer.frame = CGRect(x: 0, y: bounds.height - 30, width: bounds.width, height: 30)
    }
}

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    static let reuseIdentifier = "ImagesListCell"
}
