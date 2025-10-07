//
//  GPTCatUITests.swift
//  GPTCatUITests
//
//  Created by Ivan Sergeyenko on 2025-10-01.
//

import XCTest

final class GPTCatUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // Initialize the app
        app = XCUIApplication()
        
        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app = nil
    }

    // MARK: - App Launch Tests

    @MainActor
    func testAppLaunch() throws {
        // Test that the app launches successfully
        app.launch()

        // Verify the main window appears
        XCTAssertTrue(app.windows.firstMatch.exists)
    }
}
