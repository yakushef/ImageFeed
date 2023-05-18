//
//  ViewController.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 11.05.2023.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    // MARK: - userpic
        
        let userPicView = UIImageView()
        
        userPicView.image = UIImage(named: "Photo")
        userPicView.clipsToBounds = true
        userPicView.layer.cornerRadius = 35
        userPicView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(userPicView)
        
        userPicView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        userPicView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        
    // MARK: - logout button
        
        let logoutButton = UIButton.systemButton(with: UIImage(named: "Logout")!, target: self, action: #selector(Self.logoutButtonTapped))
        
        logoutButton.tintColor = .ypRed()
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(logoutButton)
        
        logoutButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        logoutButton.centerYAnchor.constraint(equalTo: userPicView.centerYAnchor).isActive = true
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12).isActive = true
        
    // MARK: - full name label
    
        let fullNameLabel = UILabel()
        
        fullNameLabel.text = "Екатерина Новикова"
        fullNameLabel.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        fullNameLabel.textColor = .ypWhite()
        fullNameLabel.numberOfLines = 0
        fullNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(fullNameLabel)
        
        fullNameLabel.topAnchor.constraint(equalTo: userPicView.bottomAnchor, constant: 8).isActive = true
        fullNameLabel.leadingAnchor.constraint(equalTo: userPicView.leadingAnchor).isActive = true
        fullNameLabel.trailingAnchor.constraint(equalTo: logoutButton.trailingAnchor).isActive = true
        
    // MARK: - username label
        
        let usernameLabel = UILabel()
        
        usernameLabel.text = "@ekaterina_nov"
        usernameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        usernameLabel.textColor = .ypGrey()
        fullNameLabel.numberOfLines = 0
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(usernameLabel)
        
        usernameLabel.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: 8).isActive = true
        usernameLabel.leadingAnchor.constraint(equalTo: fullNameLabel.leadingAnchor).isActive = true
        usernameLabel.trailingAnchor.constraint(equalTo: fullNameLabel.trailingAnchor).isActive = true
        
    // MARK: - status label
        
        let statusLabel = UILabel()

        statusLabel.text = "Hello, world!"
        statusLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        statusLabel.textColor = .ypWhite()
        fullNameLabel.numberOfLines = 0
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(statusLabel)

        statusLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8).isActive = true
        statusLabel.leadingAnchor.constraint(equalTo: fullNameLabel.leadingAnchor).isActive = true
        statusLabel.trailingAnchor.constraint(equalTo: fullNameLabel.trailingAnchor).isActive = true
    }
    
    // MARK: - Actions
    
    @objc
    private func logoutButtonTapped() {

    }
    
}
