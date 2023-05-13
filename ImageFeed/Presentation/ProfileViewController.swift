//
//  ViewController.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 11.05.2023.
//

import UIKit

class ProfileViewController: UIViewController {

    
    @IBOutlet private var userpicView: UIImageView!
    @IBOutlet private var userStatusLabel: UILabel!
    @IBOutlet private var usernameLabel: UILabel!
    @IBOutlet private var fullNameLabel: UILabel!
    @IBOutlet private var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    @IBAction private func logoutButtonTapped(_ sender: Any) {
    }
    
}
