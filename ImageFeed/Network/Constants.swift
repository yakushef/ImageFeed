//
//  Constants.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 25.05.2023.
//

import Foundation

let SecretKey: String = "9mXLRPUqu5mOJlrceqRVYBF37XqfAB_PxxkXBt1Qt3U"
let AccessKey: String = "eE7l1owI6o3P-VryqH933HKWbmXxc-wB8UckSyuFfEw"
let RedirectURI: String = "urn:ietf:wg:oauth:2.0:oob"
let AccessScope: String = "public+read_user+write_likes"

let DefaultBaseURL: URL = {
    guard let url = URL(string: "https://api.unsplash.com/") else { assertionFailure("Invalid Base URL"); return URL(string: "")! }
    return url
}()

