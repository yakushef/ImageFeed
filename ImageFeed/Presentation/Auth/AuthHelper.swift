//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 09.07.2023.
//

import Foundation

protocol AuthHelperProtocol: AnyObject {
    func authRequest() -> URLRequest
    func code(from url: URL) -> String?
}

final class AuthHelper: AuthHelperProtocol {
    private let authConfig: AuthConfiguration
    
    init(configuration: AuthConfiguration = .standard) {
        self.authConfig = configuration
    }
    
    func authRequest() -> URLRequest {
        URLRequest(url: authURL())
    }
    
    func authURL() -> URL {
        var urlComponents: URLComponents = { guard let components = URLComponents(string: authConfig.authURLString) else { assertionFailure("Invalid Authorize URLComonents"); return URLComponents() }
            return components }()
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: authConfig.accesssKey),
            URLQueryItem(name: "redirect_uri", value: authConfig.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: authConfig.accessScope)
        ]
        guard let url = urlComponents.url else {
            assertionFailure("Invalid Authorize URL")
            return URL(string: "")!
        }
        return url
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
