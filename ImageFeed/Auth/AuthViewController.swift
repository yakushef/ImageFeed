//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 25.05.2023.
//

import UIKit

class AuthViewController: UIViewController {
    
    private let authSegueID = "ShowWebView"
    let oAuth2Service = OAuth2Service()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let webViewVC = segue.destination as? WebViewViewController else {
            return
        }
        webViewVC.delegate = self
    }
    

}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        oAuth2Service.fetchAuthToken(code: code) { result in
            switch result {
            case .success(let token):
                print("token:")
                print(token)
                vc.performSegue(withIdentifier: "authorized", sender: nil)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
    
    
}
