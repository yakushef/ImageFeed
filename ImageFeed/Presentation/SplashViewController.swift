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
    let profileService = ProfileService()
    var alertPresenter: AlertPresenterProtocol!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previousAuthCheck()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sleep(5)
        
        logoView = UIImageView()
        configureUI()
    }
    
    func configureUI() {
        view.backgroundColor = .ypBlack()
        
        let logo = UIImage(named: "Vector") ?? UIImage()
        logoView.image = logo
        
        logoView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        logoView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        logoView.widthAnchor.constraint(equalToConstant: 78).isActive = true
        logoView.heightAnchor.constraint(equalToConstant: 75).isActive = true
    }

    func authDone() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid window config")
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController

        UIView.transition(with: window, duration: 0.1, options: [.transitionCrossDissolve, .overrideInheritedOptions, .curveEaseIn], animations: nil)
        
        UIBlockingProgressHUD.dismiss()
    }
    
    func getProfile(for token: String) {
        ProfileService.shared.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                ProfileService.shared.profile = profile
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { (result: Result<String, Error>) in
                    switch result {
                    case .success(let imageURLstring):
                        if let url = URL(string: imageURLstring) {
                            ProfileImageService.shared.imageURL = url
                        }
                    case .failure(let error):
                        assertionFailure("\(error.localizedDescription)")
                        }
                    }
                self.authDone()
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                alertPresenter.presentAlert(title: "Что-то пошло не так(", message: "Не удалось получить данные профиля:\n\n \(error.localizedDescription)", buttonText: "OK", completion: { [weak self] in
                    guard let self = self else { return }
                    dismiss(animated: true)
                })
            }
        }
    }
    
    func previousAuthCheck() {
        if let token = OAuth2TokenStorage().token {
//            UIBlockingProgressHUD.show()
            getProfile(for: token)
//            ProfileImageService.shared.fetchImage(fromURL: url)
//            authDone()
        } else {
            UIBlockingProgressHUD.dismiss()
//            performSegue(withIdentifier: "noAuthTokenFound", sender: nil)
            guard let authVC = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: "AuthViewController") as? AuthViewController else {
                fatalError("Cat't instantiate AuthVC")
            }
            authVC.delegate = self
            authVC.modalPresentationStyle = .fullScreen
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
            case .success(_):
//                self.authDone()
//                UIBlockingProgressHUD.dismiss()
                self.previousAuthCheck()
            case .failure(let error):
                // TODO: Handle error
                UIBlockingProgressHUD.dismiss()
                alertPresenter.presentAlert(title: "Что-то пошло не так(", message: "Не удалось войти в систему:\n\n \(error.localizedDescription)", buttonText: "OK", completion: { [weak self] in
                    guard let self = self else { return }
                    dismiss(animated: true)
                })
//                assertionFailure("\(error)")
                
            }
        }
    }
}

//extension SplashViewController {
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        if segue.identifier == "noAuthTokenFound" {
//            guard let navVC = segue.destination as? UINavigationController,
//                  let authVC = navVC.viewControllers[0] as? AuthViewController
//            else {
//                fatalError("faild to prepare for auth segue")
//            }
//            authVC.delegate = self
//        } else {
//            super.prepare(for: segue, sender: sender)
//        }
//
//    }
//}

// MARK: - Alert presenter delegate

extension SplashViewController: AlertPresenterDelegate {
    func show(alert: UIAlertController) {
        self.present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter = AlertPresenter(delegate: self)
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
