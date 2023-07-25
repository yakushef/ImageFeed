//
//  LogoutHelper.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 10.07.2023.
//

import UIKit

protocol LogoutHelperProtocol: AnyObject {
    func logout()
}

final class LogoutHelper: LogoutHelperProtocol {
    func logout() {
        ProfileService.shared.clean()
        OAuth2TokenStorage().clearTokenStorage()
        
        let splashVC = SplashViewController()
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid window config")
        }
        
        window.rootViewController = splashVC
        window.makeKeyAndVisible()
        
        UIView.transition(with: window,
                          duration: 0.1,
                          options: [.transitionCrossDissolve,
                                    .overrideInheritedOptions,
                                    .curveEaseIn],
                          animations: nil)
    }
}
