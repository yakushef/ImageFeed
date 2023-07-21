//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 25.05.2023.
//

import UIKit

protocol AuthViewControllerDelegae {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    var delegate: SplashViewController?
    private let showWebViewSegueId = "ShowWebView"
    private let authSegueID = "ShowWebView"
    let oAuth2Service = OAuth2Service()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == showWebViewSegueId else {
            fatalError("Faild to prepare for \(String(describing: segue.identifier))")
        }
        if let webViewVC = segue.destination as? WebViewViewController {
            let webViewPresenter = WebViewPresenter()
            webViewPresenter.view = webViewVC
            webViewPresenter.delegate = self
            webViewVC.presenter = webViewPresenter
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension AuthViewController: WebViewPresenterDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        self.delegate?.authViewController(self, didAuthenticateWithCode: code)
        }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
