//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 30.05.2023.
//

import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previousAuthCheck()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func authDone() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid window config")
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController

        UIView.transition(with: window, duration: 0.1, options: [.transitionCrossDissolve, .overrideInheritedOptions, .curveEaseIn], animations: nil)
    }
    
    func previousAuthCheck() {
        
        if OAuth2TokenStorage().token != nil {
            authDone()
        } else {
            performSegue(withIdentifier: "noAuthTokenFound", sender: nil)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegae {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        ProgressHUD.show()
        fetchAuthToken(code)
    }
    
    private func fetchAuthToken(_ code: String) {
        OAuth2Service.shared.fetchAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.authDone()
                ProgressHUD.dismiss()
            case .failure(let error):
                // TODO: Handle error
                ProgressHUD.dismiss()
                assertionFailure("\(error)")
            }
        }
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "noAuthTokenFound" {
            guard let navVC = segue.destination as? UINavigationController,
                  let authVC = navVC.viewControllers[0] as? AuthViewController
            else {
                fatalError("faild to prepare for auth segue")
            }
            authVC.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }

    }
}
