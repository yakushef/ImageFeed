//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 28.05.2023.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    private let wrapper = KeychainWrapper.standard
    
    private enum Keys: String {
        case AuthToken
    }
    
    var token: String? {
        get {
            let token = wrapper.string(forKey: Keys.AuthToken.rawValue)
            return token
        }
        set {
            guard let newToken = newValue else { return }
            let isSuccess = wrapper.set(newToken, forKey: Keys.AuthToken.rawValue)

            if !isSuccess {
                assertionFailure("Failed to save token")
            }
        }
    }
    
    func clearTokenStorage() {
        wrapper.remove(forKey: KeychainWrapper.Key(rawValue: Keys.AuthToken.rawValue))
        // TODO: проверить, точно ли нет странного поведения при попытке повторной авторизации после выхода
    }
}
