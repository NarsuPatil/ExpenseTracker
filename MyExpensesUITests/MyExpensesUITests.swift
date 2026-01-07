//
//  MyExpensesUITests.swift
//  MyExpensesUITests
//
//  Created by Narsu Patil on 07/01/26.
//

import XCTest

final class MyExpensesUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }
    func testAddExpense() {
        app.buttons["add_button"].tap()

        app.textFields["title_field"].tap()
        app.textFields["title_field"].typeText("Tea")

        app.textFields["amount_field"].tap()
        app.textFields["amount_field"].typeText("20")

        app.buttons["save_button"].tap()

        XCTAssertTrue(app.staticTexts["Tea"].exists)
    }
    func testEditExpense() {
        testAddExpense()

        app.staticTexts["Tea"].tap()

        let title = app.textFields["title_field"]
        title.tap()
        title.doubleTap()
        title.typeText("Coffee")

        app.buttons["save_button"].tap()

        XCTAssertTrue(app.staticTexts["Coffee"].exists)
    }
    func testDeleteExpense() {
        testAddExpense()

        let cell = app.cells.firstMatch
        XCTAssertTrue(cell.exists)

        // Swipe left to reveal system delete
        cell.swipeLeft()

        // Tap system delete button
        app.buttons["Delete"].tap()

        XCTAssertFalse(app.staticTexts["Tea"].exists)
    }
    func testSearch() {
        testAddExpense()

        // Make sure we are on Expenses tab
        app.tabBars.buttons["Expenses"].tap()

        let searchField = app.textFields["SearchTextField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))

        searchField.tap()
        searchField.typeText("Tea")

        XCTAssertTrue(app.staticTexts["Tea"].waitForExistence(timeout: 2))
    }
}
