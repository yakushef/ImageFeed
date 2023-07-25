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
    
        guard let imagesListVC = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as? ImagesListViewController else {
            fatalError("Cannot instantiate ImagesListVC")
        }
        imagesListVC.configure(ImageListViewPresenter())
            
        let profileVC = ProfileViewController()
        profileVC.configure(ProfileViewPresenter())
        profileVC.tabBarItem = UITabBarItem(
                    title: "",
                    image: UIImage(named: "Active"),
                    selectedImage: nil
                )
           
       self.viewControllers = [imagesListVC, profileVC]
       }
}
