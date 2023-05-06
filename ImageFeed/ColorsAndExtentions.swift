//
//  ColorsAndExtentions.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 03.05.2023.
//

import UIKit

extension UIColor {
    static var ypBlack = { UIColor(named: "YPBlack") ?? UIColor.black }
    static var ypGrey = { UIColor(named: "YPGray") ?? UIColor.gray }
    static var ypWhite = { UIColor(named: "YPWhite") ?? UIColor.white }
    static var ypWhiteA50 = { UIColor(named: "YPWhiteAlpha50") ?? UIColor.white }
    static var ypBackground = { UIColor(named: "YPBackground") ?? UIColor.black }
    static var ypBackgroundA20 = { UIColor(named: "YPBackgroundAlpha20") ?? UIColor.black }
    static var ypRed = { UIColor(named: "YPRed") ?? UIColor.red }
    static var ypBlue = { UIColor(named: "YPBlue") ?? UIColor.blue }
}

final class GradientImageView: UIImageView {
    
    let gradientLayer = CAGradientLayer()
    
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
