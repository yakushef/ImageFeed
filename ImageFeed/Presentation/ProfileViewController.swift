//
//  ViewController.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 11.05.2023.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private var userPicView: UIImageView!
    private var logoutButton: UIButton!
    private var fullNameLabel: UILabel!
    private var usernameLabel: UILabel!
    private var statusLabel: UILabel!
    
    private let profileService = ProfileService.shared
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private var currentProfile: Profile = Profile(username: "", firstName: "", lastName: "", bio: "")
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: ProfileImageService.DidChangeNotification,
                                               object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.updateUserPic()
        }
        
        view.backgroundColor = .ypBlack()
        
        userPicView = UIImageView()
        view.addSubview(userPicView)
        
        logoutButton = UIButton.systemButton(with: UIImage(), target: self, action: #selector(Self.logoutButtonTapped))
        view.addSubview(logoutButton)
        
        fullNameLabel = UILabel()
        view.addSubview(fullNameLabel)
        
        usernameLabel = UILabel()
        view.addSubview(usernameLabel)
        
        statusLabel = UILabel()
        view.addSubview(statusLabel)
        
        configureUI()
        getProfileData()
        
        updateUserPic()
    }
    
    
    private func getProfileData() {
        guard let profile = profileService.profile else { return }
        
        currentProfile = profile
        
        fullNameLabel.text = currentProfile.name
        usernameLabel.text = currentProfile.loginName
        statusLabel.text = currentProfile.bio
    }
    
    private func configureUI() {
        // MARK: - userpic
        userPicView.backgroundColor = .ypWhite()
        userPicView.image = UIImage(named: "ProfilePlaceholder") ?? UIImage()
        userPicView.clipsToBounds = true
        userPicView.layer.cornerRadius = 35
        userPicView.translatesAutoresizingMaskIntoConstraints = false
        userPicView.contentMode = .scaleAspectFill
        
        userPicView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        userPicView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        
        userPicView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        userPicView.widthAnchor.constraint(equalTo: userPicView.heightAnchor, multiplier: 1).isActive = true
        
        // MARK: - logout button
        let logoutImage = UIImage(named: "Logout") ?? UIImage()
        logoutButton.setImage(logoutImage, for: .normal)
        logoutButton.tintColor = .ypRed()
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        logoutButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        logoutButton.centerYAnchor.constraint(equalTo: userPicView.centerYAnchor).isActive = true
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12).isActive = true
        
        // MARK: - full name label
        fullNameLabel.text = "Екатерина Новикова"
        fullNameLabel.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        fullNameLabel.textColor = .ypWhite()
        fullNameLabel.numberOfLines = 0
        fullNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        fullNameLabel.topAnchor.constraint(equalTo: userPicView.bottomAnchor, constant: 8).isActive = true
        fullNameLabel.leadingAnchor.constraint(equalTo: userPicView.leadingAnchor).isActive = true
        fullNameLabel.trailingAnchor.constraint(equalTo: logoutButton.trailingAnchor).isActive = true
        
        // MARK: - username label
        
        usernameLabel.text = "@ekaterina_nov"
        usernameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        usernameLabel.textColor = .ypGrey()
        fullNameLabel.numberOfLines = 0
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        usernameLabel.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: 8).isActive = true
        usernameLabel.leadingAnchor.constraint(equalTo: fullNameLabel.leadingAnchor).isActive = true
        usernameLabel.trailingAnchor.constraint(equalTo: fullNameLabel.trailingAnchor).isActive = true
        
        // MARK: - status label
        statusLabel.text = "Hello, world!"
        statusLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        statusLabel.textColor = .ypWhite()
        fullNameLabel.numberOfLines = 0
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        statusLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8).isActive = true
        statusLabel.leadingAnchor.constraint(equalTo: fullNameLabel.leadingAnchor).isActive = true
        statusLabel.trailingAnchor.constraint(equalTo: fullNameLabel.trailingAnchor).isActive = true
    }
    
    // MARK: - Actions
    
    @objc private func logoutButtonTapped() {
        let splashVC = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "AuthViewController")
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid window config")
        }
        
        profileService.profile = nil
        OAuth2TokenStorage().clearTokenStorage()
        
        window.rootViewController = splashVC
        window.makeKeyAndVisible()
        
        UIView.transition(with: window,
                          duration: 0.1,
                          options: [.transitionCrossDissolve,
                            .overrideInheritedOptions,
                            .curveEaseIn],
                          animations: nil)
    }
    
}

// MARK: - Observer
extension ProfileViewController {
    private func updateUserPic() {
        guard let imageURL = ProfileImageService.shared.imageURL else { return }
        let placeholder = UIImage(named: "ProfilePlaceholder") ?? UIImage()
        userPicView.kf.setImage(with: imageURL,
                                placeholder: placeholder,
                                options: [.transition(.fade(0.5))])
    }
}
