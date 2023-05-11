//
//  ViewController.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 11.05.2023.
//

import UIKit

class ProfileViewController: UIViewController {

    
    @IBOutlet weak var userpicView: UIImageView!
    @IBOutlet weak var userStatusLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
    }
    
}
