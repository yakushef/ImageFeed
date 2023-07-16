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
        loginTextField.typeText("")
        webView.swipeUp()
        // MARK: - ACCOUNT PASSWORD
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        passwordTextField.typeText("")
        webView.swipeUp()
        
        webView.buttons.matching(identifier: "Login").element.tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        sleep(5)
        let tablesQuery = app.tables.matching(identifier: "ImageList")
        sleep(20)
        let cells = tablesQuery.cells.allElementsBoundByIndex
        sleep(20)
        
        var exampleCell: XCUIElement!
        var exampleCellButton: XCUIElement!
        
        for cell in cells {
            guard cell.exists,
                  cell.buttons.element.exists else { return }
            let likeButton = cell.buttons.element
            if likeButton.isEnabled && cell.isEnabled {
                if likeButton.isHittable && cell.isHittable {
                    exampleCell = cell
                    exampleCellButton = likeButton }
                break
            }
        }
        
//        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(exampleCell.waitForExistence(timeout: 10))
        XCTAssertTrue(exampleCellButton.waitForExistence(timeout: 10))
        
        exampleCellButton.tap()
        sleep(20)
        exampleCell.tap()
//        app.swipeUp()
//        sleep(3)
//        app.swipeDown()
//        sleep(3)
//
//        let testCell = tablesQuery.children(matching: .cell).element(boundBy: 1)
//        XCTAssertTrue(testCell.waitForExistence(timeout: 20))
//        sleep(20)
//        let likeButton = testCell.buttons.element
//        XCTAssertTrue(likeButton.waitForExistence(timeout: 20))
//        sleep(20)
//        likeButton.tap()
//        testCell.buttons.element.tap()
//        sleep(5)
//        testCell.buttons.matching(identifier: "likeButtonActive").element.tap()
//        testCell.buttons.element.tap()
//        sleep(2)
//        sleep(20)
//        testCell.tap()

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
        XCTAssertTrue(app.staticTexts["Povar Vrach"].exists)
        XCTAssertTrue(app.staticTexts["@yakushef"].exists)
        
        app.buttons["Logout Button"].tap()
        
        app.alerts["Logout Alert"].scrollViews.otherElements.buttons["Yes"].tap()
    }
}
