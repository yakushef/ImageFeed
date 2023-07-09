//
//  WebViewViewPresenter.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 09.07.2023.
//

import UIKit

public protocol WebViewViewPresenterProtocol: AnyObject {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

final class WebViewPresenter: WebViewViewPresenterProtocol {
    weak var view: WebViewViewControllerProtocol?
    
    let authConfig = AuthConfiguration.standard
    
    func viewDidLoad() {
        var urlComponents: URLComponents = { guard let components = URLComponents(string: authConfig.authURLString) else { assertionFailure("Invalid Authorize URLComonents"); return URLComponents() }
            return components }()
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: authConfig.accesssKey),
            URLQueryItem(name: "redirect_uri", value: authConfig.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: authConfig.accessScope)
        ]
        let url: URL = {
            guard let url = urlComponents.url else {
                assertionFailure("Invalid Authorize URL")
                return URL(string: "")!
            }
            return url
        }()
        let request = URLRequest(url: url)
        
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
        if let urlComponents = URLComponents(string: url.absoluteString),
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
