//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 30.05.2023.
//

import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
    private var logoView: UIImageView!
    
    var profile: Profile? = nil
    
    private let profileImageService = ProfileImageService.shared
    private let profileService = ProfileService.shared
    private var alertPresenter: AlertPresenterProtocol!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        previousAuthCheck()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter = AlertPresenter(delegate: self)
        
        logoView = UIImageView()
        configureUI()

    }
    
    // MARK: - UI
    
    func configureUI() {
        view.backgroundColor = .ypBlack()
        
        let logo = UIImage(named: "Vector") ?? UIImage()
        logoView.image = logo
        logoView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(logoView)
        
        logoView.centerXAnchor
            .constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
            .isActive = true
        logoView.centerYAnchor
            .constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
            .isActive = true
        logoView.widthAnchor
            .constraint(equalToConstant: 78)
            .isActive = true
        logoView.heightAnchor
            .constraint(equalToConstant: 75)
            .isActive = true
    }
    
    // MARK: - Auth and Profile

    func authDone() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid window config")
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController

        UIView.transition(with: window,
                          duration: 0.1,
                          options: [.transitionCrossDissolve,
                            .overrideInheritedOptions,
                            .curveEaseIn],
                          animations: nil)
        
        UIBlockingProgressHUD.dismiss()
    }
    
    func getProfile(for token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.profileService.profile = profile
                self.profileImageService.fetchProfileImageURL(username: profile.username) { (result: Result<String, Error>) in
                    switch result {
                    case .success(let imageURLstring):
                        if let url = URL(string: imageURLstring) {
                            self.profileImageService.imageURL = url
                        }
                    case .failure(let error):
                        assertionFailure("\(error.localizedDescription)")
                        }
                    }
                self.dismiss(animated: true)
                self.authDone()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                self.showAlert(with: "Не удалось войти в систему:\n\n \(error.localizedDescription)")
            }
        }
    }
    
    func previousAuthCheck() {
        if let token = OAuth2TokenStorage().token,
           !token.isEmpty {
            UIBlockingProgressHUD.show()
            getProfile(for: token)
        } else {
            guard let authVC = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: "AuthViewController") as? AuthViewController else {
                fatalError("Cat't instantiate AuthVC")
            }
            authVC.delegate = self
            authVC.modalPresentationStyle = .fullScreen
            authVC.modalTransitionStyle = .crossDissolve
            self.present(authVC, animated: true)
        }
    }
}

// MARK: - Auth VC delegate

extension SplashViewController: AuthViewControllerDelegae {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        fetchAuthToken(code)
    }
    
    private func fetchAuthToken(_ code: String) {
        OAuth2Service.shared.fetchAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                guard !token.isEmpty else { assertionFailure("broken token"); return }
                dismiss(animated: true)
            case .failure(let error):
                self.showAlert(with: "Не удалось войти в систему:\n\n \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Alert presenter delegate

extension SplashViewController: AlertPresenterDelegate {
    func show(alert: UIAlertController) {
        present(alert, animated: true)
    }
    
    func showAlert(with message: String) {
        UIBlockingProgressHUD.dismiss()
        self.dismiss(animated: true)
        alertPresenter.presentAlert(title: "Что-то пошло не так(",
                                    message: message,
                                    buttonText: "OK",
                                    completion: { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true)
        })
    }
}

// MARK: - Status bar style

extension SplashViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
}
