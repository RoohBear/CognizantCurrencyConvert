//
//  FavoritesUITests.swift
//  CognizantCurrencyDemoUITests
//
//  Created by Ben Balcomb on 3/28/22.
//

import XCTest

class FavoritesUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launch()
        app.tabBars.buttons.element(boundBy: 1).tap()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testNavigateToFavorites() throws {
        XCTAssert(app.navigationBars["Favorites"].exists)
    }

    func testRefreshButtonIsHittable() {
        XCTAssertTrue(app.navigationBars.buttons["Refresh"].isHittable)
    }

    func testTapEditButton() {
        let editButton = app.navigationBars.buttons["Compose"]
        editButton.tap()
        XCTAssert(app.navigationBars["Options"].exists)
    }
}
