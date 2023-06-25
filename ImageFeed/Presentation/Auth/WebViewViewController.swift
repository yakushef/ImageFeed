//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 25.05.2023.
//

import UIKit
import WebKit

protocol WebViewViewControllerDelegate {
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {
    
    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private weak var progressBar: UIProgressView!
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    var delegate: WebViewViewControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressBar.progress = 0
        webView.navigationDelegate = self
        
        estimatedProgressObservation = webView.observe(\.estimatedProgress,
                                                        changeHandler: { [weak self] _, _ in
            guard let self = self else { return }
            updateProgress()
        })
        
        let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"

        var urlComponents: URLComponents = { guard let components = URLComponents(string: UnsplashAuthorizeURLString) else { assertionFailure("Invalid Authorize URLComonents"); return URLComponents() }
            return components }()
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: AccessKey),
            URLQueryItem(name: "redirect_uri", value: RedirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: AccessScope)
        ]
        let url: URL = {
            guard let url = urlComponents.url else {
                assertionFailure("Invalid Authorize URL")
                return URL(string: "")!
            }
            return url
        }()
        let request = URLRequest(url: url)
        
        webView.load(request)
    }
    
    private func updateProgress() {
        let progress = Float(webView.estimatedProgress)
        progressBar.setProgress(progress, animated: false)
        progressBar.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    @IBAction private func bacButtonTapped(_ sender: Any?) {
        delegate?.webViewViewControllerDidCancel(self)
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        if let code = code(from: navigationAction) {
                self.delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel, preferences)
        } else {
            decisionHandler(.allow, preferences)
        }
    }
    
    private func code(from navifationAction: WKNavigationAction) -> String? {
        
        if
            let url = navifationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
