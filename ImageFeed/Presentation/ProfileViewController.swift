//
//  ViewController.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 11.05.2023.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    private var userPicView: UIImageView!
    private var logoutButton: UIButton!
    private var fullNameLabel: UILabel!
    private var usernameLabel: UILabel!
    private var statusLabel: UILabel!
    
    private var currentProfile: Profile = Profile(username: "", firstName: "", lastName: "")
    private var profileImage: UIImage = UIImage(named: "Stub") ?? UIImage()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        ProfileImageService.shared.fetchProfileImageURL(username: currentProfile.username) { [weak self] (result: Result<String, Error>) in
            
            switch result {
            case .success(let imageURLstring):
                guard let imageURL = URL(string: imageURLstring) else { assertionFailure("wrongImageUrl"); return }
                
                var imageData = Data()
                DispatchQueue.main.async {
                    do {
                        imageData = try Data(contentsOf: imageURL)
                        self?.profileImage = UIImage(data: imageData) ?? UIImage()
                        UIView.animate(withDuration: 0.2) {
                            self?.userPicView.image = self?.profileImage
                        }
                    }
                    catch {}
                }
                
            case .failure(let error):
                assertionFailure("\(error)")
            }
        }
        
        userPicView.image = profileImage
    }
    
//    func getProfile(for token: String) {
//        ProfileService.shared.fetchProfile(token) { result in
//            switch result {
//            case .success(let profile):
//                ProfileService.shared.profile = profile
//                UIBlockingProgressHUD.dismiss()
//            case .failure(let error):
//                assertionFailure("\(error)")
//            }
//        }
//    }
    
    private func getProfileData() {
//        guard let token = OAuth2TokenStorage().token else { return }
        
//        getProfile(for: token)
        
        guard let profile = ProfileService.shared.profile else { return }
        
        currentProfile = profile
        
        fullNameLabel.text = currentProfile.name
        usernameLabel.text = currentProfile.loginName
        statusLabel.text = currentProfile.bio
    }
    
    private func configureUI() {
        // MARK: - userpic
        userPicView.image = profileImage
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
        
    }
    
}
