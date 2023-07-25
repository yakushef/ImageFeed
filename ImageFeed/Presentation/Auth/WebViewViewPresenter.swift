//
//  WebViewViewPresenter.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 09.07.2023.
//

import Foundation

protocol WebViewViewPresenterProtocol: AnyObject {
    var view: WebViewViewControllerProtocol? { get set }
    var delegate: WebViewPresenterDelegate? { get set }
    
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
    
    func webViewDidCancel()
    func webViewDidAuthWith(code: String)
}

protocol WebViewPresenterDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController,
                               didAuthenticateWithCode code: String)

    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewPresenter: WebViewViewPresenterProtocol {
    func webViewDidCancel() {
        guard let view = view as? WebViewViewController else { return }
        delegate?.webViewViewControllerDidCancel(view)
    }
    
    func webViewDidAuthWith(code: String) {
        guard let view = view as? WebViewViewController else { return }
        delegate?.webViewViewController(view, didAuthenticateWithCode: code)
    }
    
    weak var view: WebViewViewControllerProtocol?
    weak var delegate: WebViewPresenterDelegate?
    
    let authConfig = AuthConfiguration.standard
    
    var authHelper: AuthHelperProtocol
    
    init(authHelper: AuthHelperProtocol = AuthHelper()) {
        self.authHelper = authHelper
    }
    
    func viewDidLoad() {
        let request = authHelper.authRequest()
        view?.load(request: request)
        didUpdateProgressValue(0)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
}
