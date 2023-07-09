//
//  Constants.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 25.05.2023.
//

import Foundation

private let SecretKey: String = "9mXLRPUqu5mOJlrceqRVYBF37XqfAB_PxxkXBt1Qt3U"
private let AccessKey: String = "eE7l1owI6o3P-VryqH933HKWbmXxc-wB8UckSyuFfEw"
private let RedirectURI: String = "urn:ietf:wg:oauth:2.0:oob"
private let AccessScope: String = "public+read_user+write_likes"

private let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"

private let DefaultBaseURL: URL = {
    guard let url = URL(string: "https://api.unsplash.com/") else {
        assertionFailure("Invalid Base URL")
        return URL(string: "")!
        
    }
    return url 
}()

struct AuthConfiguration {
    let secretkey: String
    let accesssKey: String
    let redirectURI: String
    let accessScope: String
    let authURLString: String
    let baseURL: URL
    
    init(secretkey: String,
         accesssKey: String,
         redirectURI: String,
         accessScope: String,
         authURLString: String,
         baseURL: URL) {
        self.secretkey = secretkey
        self.accesssKey = accesssKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.authURLString = authURLString
        self.baseURL = baseURL
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(secretkey: SecretKey,
                                 accesssKey: AccessKey,
                                 redirectURI: RedirectURI,
                                 accessScope: AccessScope,
                                 authURLString: UnsplashAuthorizeURLString,
                                 baseURL: DefaultBaseURL)
    }
}
