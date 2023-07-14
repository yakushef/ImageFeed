//
//  ImageFeedProfileViewTests.swift
//  ImageFeedTests
//
//  Created by Aleksey Yakushev on 10.07.2023.
//
@testable import ImageFeed
import XCTest

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    var profileVC: ImageFeed.ProfileViewControllerProtocol?
    var isGetProfileDataCalled = false
    var isUpdateUserPicCalled = false
    
    func getProfileData() {
        isGetProfileDataCalled = true
    }
    
    func updateUserPic() {
        isUpdateUserPicCalled = true
    }
    
    func logout() {
        
    }
}

final class LogoutHelperSpy: LogoutHelperProtocol {
    var isLogoutCalled = false
    func logout() {
        isLogoutCalled = true
    }
}

final class ImageFeedProfileViewTests: XCTestCase {
    
    func testHelperLogoutIsCalled() {
        // given
        let helper = LogoutHelperSpy()
        let presenter = ProfileViewPresenter(logoutHelper: helper)
        
        // when
        presenter.logout()
        
        // then
        XCTAssertTrue(helper.isLogoutCalled)
    }
    
    func testPresenterGetProfileDataIsCalled() {
        // given
        let presenter = ProfileViewPresenterSpy()
        let profileVC = ProfileViewController()
        profileVC.configure(presenter)
        
        // when
        _ = profileVC.view
        
        // then
        XCTAssertTrue(presenter.isGetProfileDataCalled)
    }
    
    func testPresenterUpdateUserpicIsCalled() {
        // given
        let presenter = ProfileViewPresenterSpy()
        let profileVC = ProfileViewController()
        profileVC.configure(presenter)
        
        // when
        _ = profileVC.view
        
        // then
        XCTAssertTrue(presenter.isUpdateUserPicCalled)
    }
}

