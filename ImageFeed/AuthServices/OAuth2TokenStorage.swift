//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 28.05.2023.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    let wrapper = KeychainWrapper.standard

    private let userDefaults = UserDefaults.standard
    private enum Keys: String {
//        case token
        case AuthToken
    }
    
    var token: String? {
        get {
//            guard let token = userDefaults.string(forKey: Keys.token.rawValue) else { return nil }
            let token = wrapper.string(forKey: Keys.AuthToken.rawValue)
            // TODO: отработать ошибку?
            return token
        }
        set {
            guard let newToken = newValue else { return }
            let isSuccess = wrapper.set(newToken, forKey: Keys.AuthToken.rawValue)
            
//            userDefaults.set(newToken, forKey: Keys.token.rawValue)
        }
    }
}
