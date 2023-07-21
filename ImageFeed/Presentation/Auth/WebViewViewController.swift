//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 25.05.2023.
//

import UIKit
import WebKit

protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}


final class WebViewViewController: UIViewController & WebViewViewControllerProtocol {

    var presenter: WebViewViewPresenterProtocol?
    
    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private weak var progressBar: UIProgressView!
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.accessibilityIdentifier = "UnsplashWebView"
        
        progressBar.progress = 0
        webView.navigationDelegate = self
        
        presenter?.viewDidLoad()
        
        estimatedProgressObservation = webView.observe(\.estimatedProgress,
                                                        changeHandler: { [weak self] _, _ in
            guard let self = self else { return }
            self.presenter?.didUpdateProgressValue(webView.estimatedProgress)
        })
    }
    
    func load(request: URLRequest) {
        webView.load(request)
    }
    
    func setProgressValue(_ newValue: Float) {
        progressBar.setProgress(newValue, animated: false)
    }
    func setProgressHidden(_ isHidden: Bool) {
        progressBar.isHidden = isHidden
    }
    
    @IBAction private func backButtonTapped(_ sender: Any?) {
        presenter?.webViewDidCancel()
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        
        if let url = navigationAction.request.url,
           let code = presenter?.code(from: url) {
            presenter?.webViewDidAuthWith(code: code)
            decisionHandler(.cancel, preferences)
        } else {
            decisionHandler(.allow, preferences)
        }
    }
}
