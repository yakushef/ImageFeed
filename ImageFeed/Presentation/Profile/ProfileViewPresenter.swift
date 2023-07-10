//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Aleksey Yakushev on 10.07.2023.
//

import UIKit

protocol ProfileViewPresenterProtocol: AnyObject {
    var profileVC: ProfileViewControllerProtocol? { get set }
    
    func getProfileData()
    func updateUserPic()
    
    func logout()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    
    var profileVC: ProfileViewControllerProtocol?
    private var logoutHelper: LogoutHelperProtocol
    
    private let profileService = ProfileService.shared
    
    init(logoutHelper: LogoutHelperProtocol = LogoutHelper()) {
        self.logoutHelper = logoutHelper
        
        // MARK: - Observer
        NotificationCenter.default.addObserver(forName: ProfileImageService.DidChangeNotification,
                                               object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
                self.updateUserPic()
        }
    }
    
    // MARK: - Profile Info
    
    func getProfileData() {
        guard let profile = profileService.profile else { return }
        profileVC?.updateProfileInfo(for: profile)
    }
    
    func updateUserPic() {
        guard let imageURL = ProfileImageService.shared.imageURL else { return }
        let placeholder = UIImage(named: "ProfilePlaceholder") ?? UIImage()
        
        profileVC?.updateUserPic(with: imageURL, placeholder: placeholder)
    }
    
    // MARK: - Logout
    
    func logout() {
        logoutHelper.logout()
    }
}
