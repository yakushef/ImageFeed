//
//  GradientImageView.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 06.05.2023.
//

import UIKit

final class GradientImageView: UIImageView {
    
    private let gradientLayer = CAGradientLayer()
    
    override func awakeFromNib() {

        gradientLayer.colors = [UIColor(named: "YPBackgroundAlpha20")?.cgColor ?? UIColor.black.cgColor, UIColor.clear.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)

        layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = CGRect(x: 0, y: bounds.height - 30, width: bounds.width, height: 30)
    }
}
