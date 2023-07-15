//
//  ViewController.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 11.05.2023.
//

import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }
    
    func updateProfileInfo(for profile: Profile)
    func updateUserPic(with imageURL: URL, placeholder: UIImage)
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    var presenter: ProfileViewPresenterProtocol?
    
    private var userPicView: UIImageView!
    private var logoutButton: UIButton!
    private var fullNameLabel: UILabel!
    private var usernameLabel: UILabel!
    private var statusLabel: UILabel!
    
    private var alertPresenter: AlertPresenterProtocol!
    
    private var animationLayers = [CALayer]()
    private var gradient: CAGradientLayer!
    private var gradientAnimation: CABasicAnimation!
    private var usernameGradient: CAGradientLayer!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        
        gradient.add(gradientAnimation, forKey: "locationsChange")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter = AlertPresenter(delegate: self)
        
        addUI()
        configureUI()
        
        gradient = configureGradient(ofSize: CGSize(width: 70, height: 70))
        configureAnimation(for: gradient, in: userPicView)
        
        presenter?.getProfileData()
        presenter?.updateUserPic()
    }
    
    //MARK: - Presenter config
    
    func configure(_ presenter: ProfileViewPresenterProtocol) {
        self.presenter = presenter
        presenter.profileVC = self
    }
    
    func configureAnimation(for gradient: CAGradientLayer, in view: UIView) {
        animationLayers.append(gradient)
        view.layer.addSublayer(gradient)
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.5
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [-2, -1, 0]
        gradientChangeAnimation.toValue = [1, 2, 3]
        gradientAnimation = gradientChangeAnimation
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
    }
    
    func configureGradient(ofSize size: CGSize) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: size)
        gradient.locations = [-0.01, 0.25, 0.5]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor,
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = size.height / 2
        gradient.masksToBounds = true
        return gradient
    }
    
    // MARK: - UI Config
    private func addUI() {
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
    }
    
    private func configureUI() {
        view.backgroundColor = .ypBlack()
        
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
        fullNameLabel.text = "..."
        fullNameLabel.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        fullNameLabel.textColor = .ypWhite()
        fullNameLabel.numberOfLines = 0
        fullNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        fullNameLabel.topAnchor.constraint(equalTo: userPicView.bottomAnchor, constant: 8).isActive = true
        fullNameLabel.leadingAnchor.constraint(equalTo: userPicView.leadingAnchor).isActive = true
        fullNameLabel.trailingAnchor.constraint(equalTo: logoutButton.trailingAnchor).isActive = true
        
        // MARK: - username label
        
        usernameLabel.text = "@..."
        usernameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        usernameLabel.textColor = .ypGrey()
        fullNameLabel.numberOfLines = 0
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        usernameLabel.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: 8).isActive = true
        usernameLabel.leadingAnchor.constraint(equalTo: fullNameLabel.leadingAnchor).isActive = true
        usernameLabel.trailingAnchor.constraint(equalTo: fullNameLabel.trailingAnchor).isActive = true
        
        // MARK: - status label
        statusLabel.text = "..."
        statusLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        statusLabel.textColor = .ypWhite()
        fullNameLabel.numberOfLines = 0
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        statusLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8).isActive = true
        statusLabel.leadingAnchor.constraint(equalTo: fullNameLabel.leadingAnchor).isActive = true
        statusLabel.trailingAnchor.constraint(equalTo: fullNameLabel.trailingAnchor).isActive = true
    }
    
    // MARK: - info update
    
    func updateProfileInfo(for profile: Profile) {
        fullNameLabel.text = profile.name
        usernameLabel.text = profile.loginName
        statusLabel.text = profile.bio
    }
    
    func updateUserPic(with imageURL: URL, placeholder: UIImage) {
        userPicView.kf.setImage(with: imageURL,
                                placeholder: placeholder,
                                options: [.transition(.fade(0.5))]) { [weak self] _ in
            guard let self else { return }
            UIView.transition(with: self.userPicView,
                              duration: 0.5,
                              options: .transitionCrossDissolve,
                              animations: {
                self.gradient.isHidden = true
            },
                              completion: { _ in
                self.gradient.removeFromSuperlayer()
            })
        }
    }
    
    // MARK: - Logout
    
    @objc private func logoutButtonTapped() {
        let logoutAlert = UIAlertController(title: "Пока, пока!", message: "Уверены что хотите выйти?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.presenter?.logout()
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

// MARK: - Alert Presenter
extension ProfileViewController: AlertPresenterDelegate {
    func show(alert: UIAlertController) {
        present(alert, animated: true)
    }
}
