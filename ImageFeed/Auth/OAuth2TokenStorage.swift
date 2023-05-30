//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 28.05.2023.
//

import Foundation

protocol OAuth2TokenStorageService {
    
}

final class OAuth2TokenStorage {

    private let userDefaults = UserDefaults.standard
    private enum Keys: String {
        case token
    }
    
    var token: String? {
        get {
            guard let token = userDefaults.string(forKey: Keys.token.rawValue) else { return nil }
            // TODO: отработать ошибку?
            return token
        }
        set {
            let newToken = newValue
            userDefaults.set(newToken, forKey: Keys.token.rawValue)
        }
    }
}
