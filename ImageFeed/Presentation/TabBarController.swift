//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 20.06.2023.
//

import UIKit

final class TabBarController: UITabBarController {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
    
        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        )
            
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
                    title: "",
                    image: UIImage(named: "Active"),
                    selectedImage: nil
                )
           
       self.viewControllers = [imagesListViewController, profileViewController]
        
       }

}
