//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 12.06.2023.
//

import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        UIApplication.shared.windows.first
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.show()
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
