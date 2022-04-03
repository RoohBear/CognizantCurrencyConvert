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
    private var cell: XCUIElement?
    
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        apiKey = ProcessInfo.processInfo.environment[enviornmentKey]
        app.launchEnvironment = [enviornmentKey: apiKey]
        
        // Navigate to the CurrencyPickerViewController
        app.launch()
        app.tabBars.buttons.element(boundBy: 1).tap()
        app.navigationBars.buttons["Compose"].tap()
        
        setCell(at: 0, tapCell: true)
    }
    
    override func tearDownWithError() throws {
        app = nil
        apiKey = nil
        cell = nil
    }
    
    private func setCell(at index: Int, tapCell: Bool) {
        cell = app.tables.element(boundBy: 0).cells.element(boundBy: index)
       
        if tapCell {
            XCTAssertTrue(cell!.waitForExistence(timeout: 5))
            cell!.tap()
        }
    }
    
    func testCurrencyPickerExists_WhenBaseCurrencyCellTapped_ShouldShowCurrencyPickerController() {
        XCTAssert(app.navigationBars["Base Currency"].exists)
    }
    
    func testCurrencyPickerSelectCurrency_WhenCurrencySelected_ShouldUpdateOptionsViewController() {
        // Select the second row in the CurrencyPickerViewController table and navigate back to the options controller.
        
        setCell(at: 1, tapCell: true)
        
        let baseCellTitle = cell?.identifier
        
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        setCell(at: 0, tapCell: false)
        
        let optionCellTitle = cell?.identifier
        
        XCTAssertEqual(baseCellTitle, optionCellTitle)
    }
}
