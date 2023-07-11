//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Aleksey Yakushev on 09.07.2023.
//

@testable import ImageFeed
import XCTest

final class WebViewPresenterSpy: WebViewViewPresenterProtocol {
    var view: ImageFeed.WebViewViewControllerProtocol?
    var isViewDidLoadCalled = false
    
    func viewDidLoad() {
        isViewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        
    }
    
    func code(from url: URL) -> String? {
        return nil
    }
}

final class WebViewVCSpy: WebViewViewControllerProtocol {
    var presenter: ImageFeed.WebViewViewPresenterProtocol?
    var isLoadCalled = false
    
    func load(request: URLRequest) {
        isLoadCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {
        
    }
    
    func setProgressHidden(_ isHidden: Bool) {

    }
}

final class ImageFeedWebViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let webVC = storyboard.instantiateViewController(withIdentifier: "WebView") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        presenter.view = webVC
        webVC.presenter = presenter
        
        //when
        _ = webVC.view
        
        //then
        XCTAssertTrue(presenter.isViewDidLoadCalled)
    }
    
    func testPresenterCallsLoadRequest() {
        //given
        let webVC = WebViewVCSpy()
        let presenter = WebViewPresenter()
        webVC.presenter = presenter
        presenter.view = webVC
        
        //when
        presenter.viewDidLoad()
        //then
        XCTAssertTrue(webVC.isLoadCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        //given
        let presenter = WebViewPresenter()
        let progress: Float = 0.6
        
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //then
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        //given
        let presenter = WebViewPresenter()
        let progress: Float = 1
        
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //then
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        //given
        let authConfig = AuthConfiguration.standard
        let helper = AuthHelper(configuration: authConfig)
        
        //when
        let url = helper.authURL()
        let urlString = url.absoluteString
        
        //then
        XCTAssertTrue(urlString.contains(authConfig.authURLString))
        XCTAssertTrue(urlString.contains(authConfig.accesssKey))
        XCTAssertTrue(urlString.contains(authConfig.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(authConfig.accessScope))
    }
    
    func testCodeFromURL() {
        //given
        let testCode = "test code"
        var testURLcomponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        testURLcomponents.queryItems = [URLQueryItem(name: "code", value: testCode)]
        
        let helper = AuthHelper()
        
        //when
        let code = helper.code(from: testURLcomponents.url!)
        
        //then
        XCTAssertEqual(code, testCode)
    }
}
