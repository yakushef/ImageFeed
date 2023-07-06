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
    
    private var alertPresenter: AlertPresenterProtocol!
    
    private var currentProfile: Profile = Profile(username: "", firstName: "", lastName: "", bio: "")
    
    
    
    var animationLayers = [CALayer]()
    let gradient = CAGradientLayer()
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter = AlertPresenter(delegate: self)
        
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
        
        
        
        
        gradient.frame = CGRect(origin: .zero, size: CGSize(width: 70, height: 70))
        gradient.locations = [-0.01, 0.25, 0.5]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
//            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor,
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = 35
        gradient.masksToBounds = true
        animationLayers.append(gradient)
        
        userPicView.layer.addSublayer(gradient)
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.5
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [-2, -1, 0]
        gradientChangeAnimation.toValue = [1, 2, 3]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
        
        
        
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
    
    // MARK: - Logout
    
    private func logout() {
        let splashVC = SplashViewController()
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid window config")
        }
        
        profileService.clean()
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

    
    @objc private func logoutButtonTapped() {
        let logoutAlert = UIAlertController(title: "Пока, пока!", message: "Уверены что хотите выйти?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.logout()
        }
        let noAction = UIAlertAction(title: "Нет", style: .cancel) { [weak self] _ in
            guard let self = self else { return }
            self.dismiss(animated: true)
        }
        logoutAlert.addAction(noAction)
        logoutAlert.addAction(yesAction)
        alertPresenter.presentAlert(alert: logoutAlert)
    }
}

// MARK: - Observer
extension ProfileViewController {
    private func updateUserPic() {
        userPicView.kf.cancelDownloadTask()
        guard let imageURL = ProfileImageService.shared.imageURL else { return }
        let placeholder = UIImage(named: "ProfilePlaceholder") ?? UIImage()
        userPicView.kf.setImage(with: imageURL,
                                placeholder: placeholder,
                                options: [.transition(.fade(0.5))]) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
                UIView.transition(with: self.userPicView,
                                  duration: 0.5,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    self.gradient.isHidden = true
                                  },
                                  completion: { _ in
                    self.gradient.removeFromSuperlayer()
                                  })
            })
        }
    }
}

// MARK: - Alert Presenter
extension ProfileViewController: AlertPresenterDelegate {
    func show(alert: UIAlertController) {
        present(alert, animated: true)
    }
}
