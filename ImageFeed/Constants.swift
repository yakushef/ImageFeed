//
//  Constants.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 25.05.2023.
//

import Foundation

enum AccessScopes: String {
    case public_scope = "public"
    case read_user
    case write_likes
    
    case write_user
    case read_photos
    case write_photos
    case write_followers
    case read_collections
    case write_collections
}

let SecretKey:String = "9mXLRPUqu5mOJlrceqRVYBF37XqfAB_PxxkXBt1Qt3U"
let AccessKey: String = "eE7l1owI6o3P-VryqH933HKWbmXxc-wB8UckSyuFfEw"
let RedirectURI: String = "urn:ietf:wg:oauth:2.0:oob"
let AccessScope: String = "public+read_user+write_likes"

let DefaultBaseURL: URL = URL(string: "https://api.unsplash.com/")!
