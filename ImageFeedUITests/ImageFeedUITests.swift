//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Aleksey Yakushev on 15.07.2023.
//

import XCTest

extension XCUIElement {
    func tapUnhittable() {
        XCTContext.runActivity(named: "Tap \(self) by coordinate") { _ in
            coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        }
    }
}

final class ImageFeedUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false

        app.launch()
    }

    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        // MARK: - ACCOUNT LOGIN
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        loginTextField.typeText("email@e.mail")
        
        webView.swipeUp()
        // MARK: - ACCOUNT PASSWORD
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        passwordTextField.typeText("password")
        webView.swipeUp()
        
        webView.buttons.matching(identifier: "Login").element.tap()
        
        sleep(5)
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        let table = app.tables.matching(identifier: "ImageList").element
        XCTAssertTrue(table.waitForExistence(timeout: 10))
        
        table.cells.element(boundBy: 0).swipeUp()
        
        let actualCell = table.cells.element(boundBy: 2)
        XCTAssertTrue(actualCell.waitForExistence(timeout: 20))

        let likeButton = actualCell.buttons["likeButtonInactive"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 10))
        likeButton.tap()
        sleep(3)
        
        let dislikeButton = actualCell.buttons["likeButtonActive"]
        XCTAssertTrue(dislikeButton.waitForExistence(timeout: 10))
        dislikeButton.tap()
        sleep(3)
        
        actualCell.tap()
        
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 10))

        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)

        let backButton = app.buttons["SingleImageBackButton"]
        backButton.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
       
        // MARK: - Name + Lastname + @username
        XCTAssertTrue(app.staticTexts["Full Name"].exists)
        XCTAssertTrue(app.staticTexts["@name"].exists)
        
        app.buttons["Logout Button"].tap()
        
        app.alerts["Logout Alert"].scrollViews.otherElements.buttons["Yes"].tap()
    }
}
