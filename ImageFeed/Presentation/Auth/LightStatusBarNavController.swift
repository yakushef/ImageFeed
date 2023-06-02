//
//  lightStatusBarNavController.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 01.06.2023.
//

import UIKit

final class LightStatusBarNavController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
}
