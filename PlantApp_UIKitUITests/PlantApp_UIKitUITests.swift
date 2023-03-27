//
//  PlantApp_UIKitUITests.swift
//  PlantApp_UIKitUITests
//
//  Created by Ezra Yeoh on 3/24/23.
//

import XCTest

final class PlantApp_UIKitUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let emailTextfield = app.textFields["Email address"]
        XCTAssertTrue(emailTextfield.exists)

        emailTextfield.tap()
        emailTextfield.typeText("ez@ez.com")


        let passwordSecureTextField = app.secureTextFields["Password"]
        XCTAssertTrue(passwordSecureTextField.exists)

        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("123456")

        let loginButton = app.buttons["Log In"]
        XCTAssertTrue(loginButton.exists)

        loginButton.tap()
        

    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
