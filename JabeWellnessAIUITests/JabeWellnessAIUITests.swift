//
//  JabeWellnessAIUITests.swift
//  JabeWellnessAIUITests
//
//  Created by Joel Reamosio Abelarde on 5/13/26.
//

import XCTest

final class JabeWellnessAIUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // xcodebuild resets the app's container between separate -only-testing invocations,
    // so onboarding can reappear even though hasSeenOnboarding was already set in a prior run.
    private func dismissOnboardingIfPresent(_ app: XCUIApplication) {
        let skipButton = app.buttons["Skip"]
        if skipButton.waitForExistence(timeout: 3) {
            skipButton.tap()
        } else {
            let getStarted = app.buttons["Get Started"]
            if getStarted.waitForExistence(timeout: 2) { getStarted.tap() }
        }
    }

    @MainActor
    func testChatSendAndNavigateTabs() throws {
        let app = XCUIApplication()
        app.launch()
        dismissOnboardingIfPresent(app)

        let textView = app.textViews.firstMatch
        XCTAssertTrue(textView.waitForExistence(timeout: 5), "Chat text editor should exist")
        textView.tap()
        textView.typeText("I'm feeling really anxious about my job interview tomorrow")

        // SF Symbol "arrow.up" / "plus.bubble" get default accessibility labels "Up" / "Comment"
        app.buttons["Up"].tap()

        let jabeLabel = app.staticTexts["Jabe"].firstMatch
        XCTAssertTrue(jabeLabel.waitForExistence(timeout: 20), "AI reply bubble should appear")

        app.buttons["Comment"].tap()

        app.tabBars.buttons["Insights"].tap()
        app.tabBars.buttons["Exercises"].tap()
        app.tabBars.buttons["Journal"].tap()
        app.tabBars.buttons["Settings"].tap()
        app.tabBars.buttons["Chat"].tap()
    }

    @MainActor
    func testHistoryShowsSavedSessions() throws {
        let app = XCUIApplication()
        app.launch()
        dismissOnboardingIfPresent(app)

        let textView = app.textViews.firstMatch
        XCTAssertTrue(textView.waitForExistence(timeout: 5), "Chat text editor should exist")
        textView.tap()
        textView.typeText("Just checking in, feeling okay today")
        app.buttons["Up"].tap()
        XCTAssertTrue(app.staticTexts["Jabe"].firstMatch.waitForExistence(timeout: 20), "AI reply bubble should appear")
        app.buttons["Comment"].tap()

        app.tabBars.buttons["Insights"].tap()
        let historyRow = app.staticTexts["Chat History"].firstMatch
        XCTAssertTrue(historyRow.waitForExistence(timeout: 5), "Chat History row should exist on Insights")
        historyRow.tap()

        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "History should list the session just saved")
        firstCell.tap()
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
