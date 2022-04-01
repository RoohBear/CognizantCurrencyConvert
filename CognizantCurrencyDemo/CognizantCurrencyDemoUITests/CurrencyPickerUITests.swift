//
//  CurrencyPickerUITests.swift
//  CognizantCurrencyDemoUITests
//
//  Created by Curtis Stilwell on 4/1/22.
//

import XCTest

class CurrencyPickerUITests: XCTestCase {
    
    private var app: XCUIApplication!
    private var apiKey: String!
    private let enviornmentKey = "CURRENCY_SCOOP_API_KEY"
    
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        apiKey = ProcessInfo.processInfo.environment[enviornmentKey]
        app.launchEnvironment = [enviornmentKey: apiKey]

        app.launch()
        app.tabBars.buttons.element(boundBy: 1).tap()
        app.navigationBars.buttons["Compose"].tap()
    }
    
    override func tearDownWithError() throws {
        app = nil
        apiKey = nil
    }
    
    func testCurrencyPickerExists_WhenBaseCurrencyCellTapped_ShouldShowCurrencyPickerController() {
        let baseCell = app.tables.element(boundBy: 0).cells.element(boundBy: 0)
        XCTAssertTrue(baseCell.waitForExistence(timeout: 5))
       
        baseCell.tap()
        XCTAssert(app.navigationBars["Base Currency"].exists)
    }
    
}
