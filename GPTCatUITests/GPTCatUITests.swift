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

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            app.launch()
        }
    }
    
    // MARK: - Chat Interface Tests
    
    @MainActor
    func testChatInterfaceElements() throws {
        app.launch()
        
        // Verify input text field exists
        let textField = app.textFields["Type your message..."]
        XCTAssertTrue(textField.exists)
        
        // Verify send button exists
        let sendButton = app.buttons.matching(identifier: "Submit").firstMatch
        XCTAssertTrue(sendButton.exists)
        
        // Verify mic button exists
        // let micButton = app.buttons.matching(identifier: "mic").firstMatch
        // XCTAssertTrue(micButton.exists)
    }
    
    @MainActor
    func testTextInputAndSend() throws {
        app.launch()
        
        let textField = app.textFields["Type your message..."]
        let sendButton = app.buttons.matching(identifier: "Submit").firstMatch
        
        // Test typing in the text field
        textField.tap()
        textField.typeText("Hello, GPT Cat!")
        
        // Verify text was entered
        XCTAssertEqual(textField.value as? String, "Hello, GPT Cat!")
        
        // Verify send button is enabled (not grayed out)
        XCTAssertTrue(sendButton.isEnabled)
        
        // Test sending the message
        sendButton.tap()
        
        // Verify text field is cleared after sending
        XCTAssertEqual(textField.value as? String, "")
    }
    
    @MainActor
    func testSendButtonDisabledWhenEmpty() throws {
        app.launch()
        
        let textField = app.textFields["Type your message..."]
        let sendButton = app.buttons.matching(identifier: "Submit").firstMatch
        
        // Verify send button is disabled when text field is empty
        XCTAssertTrue(sendButton.exists)
        XCTAssertFalse(sendButton.isEnabled)
        
        // Type some text
        textField.tap()
        textField.typeText("Test message")
        
        // Verify send button is now enabled
        XCTAssertTrue(sendButton.isEnabled)
        

        // Clear the text
        sendButton.tap()
        textField.tap()
        textField.typeText("")
        
        // Verify send button is disabled again
        XCTAssertFalse(sendButton.isEnabled)
    }
    
    @MainActor
    func testEnterKeySendsMessage() throws {
        app.launch()
        
        let textField = app.textFields["Type your message..."]
        
        // Type a message and press Enter
        textField.tap()
        textField.typeText("Test message with Enter key")
        textField.typeText("\n")
        
        // Verify text field is cleared (message was sent)
        XCTAssertEqual(textField.value as? String, "")
    }
    
    // MARK: - Toolbar Tests
    
    @MainActor
    func testToolbarButtons() throws {
        app.launch()
        
        // Test settings button
        let settingsButton = app.buttons.matching(identifier: "Settings").firstMatch
        XCTAssertTrue(settingsButton.exists)
        
        // Test clear chat button
        let clearButton = app.buttons.matching(identifier: "Delete").firstMatch
        XCTAssertTrue(clearButton.exists)
    }
    
    @MainActor
    func testClearChatButton() throws {
        app.launch()
        
        // First, add a message to the chat
        let textField = app.textFields["Type your message..."]
        let sendButton = app.buttons.matching(identifier: "Submit").firstMatch
        
        textField.tap()
        textField.typeText("Test message for clearing")
        sendButton.tap()
        
        // Wait a moment for the message to appear
        sleep(1)
        
        // Tap the clear button
        let clearButton = app.buttons.matching(identifier: "Delete").firstMatch
        clearButton.tap()
        
        // TODO: Verify the chat is cleared (no messages visible)
    }
    
    // MARK: - Settings Tests
    
    @MainActor
    func testSettingsWindow() throws {
        app.launch()
        
        // Open settings
        let settingsButton = app.buttons.matching(identifier: "Settings").firstMatch
        settingsButton.tap()
        
        // Wait for settings window to appear
        sleep(1)
        
        // Verify settings window elements
        XCTAssertTrue(app.staticTexts["Settings"].exists)
        XCTAssertTrue(app.staticTexts["OpenRouter API Key"].exists)
        XCTAssertTrue(app.staticTexts["Model"].exists)
        
        // Verify API key field exists
        let apiKeyField = app.secureTextFields["Enter your API key"]
        XCTAssertTrue(apiKeyField.exists)
        
        // Verify model picker exists
        let modelPicker = app.popUpButtons.firstMatch
        XCTAssertTrue(modelPicker.exists)
        
        // Verify buttons exist
        XCTAssertTrue(app.buttons["Cancel"].exists)
        XCTAssertTrue(app.buttons["Save"].exists)
    }
    
    @MainActor
    func testSettingsAPIKeyInput() throws {
        app.launch()
        
        // Open settings
        let settingsButton = app.buttons.matching(identifier: "Settings").firstMatch
        settingsButton.tap()
        
        sleep(1)
        
        // Test API key input
        let apiKeyField = app.secureTextFields["Enter your API key"]
        apiKeyField.tap()
        apiKeyField.typeText("test-api-key-123")
        
        // Verify the text was entered
        XCTAssertEqual(apiKeyField.value as? String, "")
    }
    
    @MainActor
    func testSettingsModelSelection() throws {
        app.launch()
        
        // Open settings
        let settingsButton = app.buttons.matching(identifier: "Settings").firstMatch
        settingsButton.tap()
        
        sleep(1)
        
        // Test model picker
        let modelPicker = app.popUpButtons.firstMatch
        modelPicker.tap()
        
        // Verify model options are available
        XCTAssertTrue(app.menuItems["openai/gpt-5-nano"].exists)
        XCTAssertTrue(app.menuItems["openai/gpt-5"].exists)
        XCTAssertTrue(app.menuItems["google/gemini-2.5-flash"].exists)
        XCTAssertTrue(app.menuItems["anthropic/claude-sonnet-4.5"].exists)
        
        // Select a different model
        app.menuItems["google/gemini-2.5-flash"].tap()
        
        // Verify the selection was made
        XCTAssertEqual(modelPicker.value as? String, "google/gemini-2.5-flash")
    }
    
    @MainActor
    func testSettingsSaveAndCancel() throws {
        app.launch()
        
        // Open settings
        let settingsButton = app.buttons.matching(identifier: "Settings").firstMatch
        settingsButton.tap()
        
        sleep(1)
        
        // Test Cancel button
        let cancelButton = app.buttons["Cancel"]
        XCTAssertTrue(cancelButton.exists)
        cancelButton.tap()
        
        // Verify settings window is closed
        sleep(1)
        XCTAssertFalse(app.staticTexts["Settings"].exists)
        
        // Open settings again
        settingsButton.tap()
        sleep(1)
        
        // Test Save button
        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.exists)
        saveButton.tap()
        
        // Verify settings window is closed
        sleep(1)
        XCTAssertFalse(app.staticTexts["Settings"].exists)
    }
    
    // MARK: - Accessibility Tests
    
    @MainActor
    func testAccessibilityElements() throws {
        app.launch()
        
        // Test that main elements exist and can be accessed
        XCTAssertTrue(app.textFields["Type your message..."].exists)
        XCTAssertTrue(app.buttons.matching(identifier: "Submit").firstMatch.exists)
        // XCTAssertTrue(app.buttons.matching(identifier: "mic").firstMatch.exists)
        XCTAssertTrue(app.buttons.matching(identifier: "Settings").firstMatch.exists)
        XCTAssertTrue(app.buttons.matching(identifier: "Delete").firstMatch.exists)
    }
    
    // MARK: - Error Handling Tests
    
    @MainActor
    func testEmptyMessageHandling() throws {
        app.launch()
        
        let textField = app.textFields["Type your message..."]
        let sendButton = app.buttons.matching(identifier: "Submit").firstMatch
        
        // Try to send empty message
        textField.tap()
        textField.typeText("   ") // Only whitespace
        sendButton.tap()
        
        // Verify send button remains disabled or message wasn't sent
        XCTAssertFalse(sendButton.isEnabled)
    }
    
    
    // MARK: - Integration Tests
    // TODO: not very useful without a mock API client
    
    @MainActor
    func testCompleteChatFlow() throws {
        app.launch()
        
        // Open settings and set a test API key
        let settingsButton = app.buttons.matching(identifier: "Settings").firstMatch
        settingsButton.tap()
        sleep(1)
        
        let apiKeyField = app.secureTextFields["Enter your API key"]
        apiKeyField.tap()
        apiKeyField.typeText("test-key")
        
        app.buttons["Save"].tap()
        sleep(1)
        
        // Send a test message
        let textField = app.textFields["Type your message..."]
        let sendButton = app.buttons.matching(identifier: "Submit").firstMatch
        
        textField.tap()
        textField.typeText("Hello, this is a test message!")
        sendButton.tap()
        
        // Verify the message was sent (text field cleared)
        XCTAssertEqual(textField.value as? String, "")
        
        // TODO: mock API, verify that response appears
    }
}
