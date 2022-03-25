//
//  OptionsRepositoryTests.swift
//  CognizantCurrencyDemoTests
//
//  Created by Ben Balcomb on 3/24/22.
//

import XCTest
import Combine
@testable import CognizantCurrencyDemo

class OptionsRepositoryTests: XCTestCase {

    private var storageKey: String { "options.storage.key" }
    private var optionsToRestore: Options!
    private var repository: OptionsRepository!
    private var fakeCurrency: Currency { Currency(currencyCode: "fake", currencyName: "fake name") }
    private var subscription: AnyCancellable?
    private var expectation: XCTestExpectation { expectation(description: "wait for publisher") }

    override func setUpWithError() throws {
        repository = OptionsRepository()
        optionsToRestore = repository.options
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    override func tearDownWithError() throws {
        storeOptions(optionsToRestore)
        repository = nil
        optionsToRestore = nil
        subscription = nil
    }

    private func storeOptions(_ options: Options) {
        guard let jsonData = try? JSONEncoder().encode(options),
              let jsonString = String(data: jsonData, encoding: .utf8)
        else {
            fatalError("failed to store options")
        }
        UserDefaults.standard.set(jsonString, forKey: storageKey)
    }

    private func assertTrue(_ condition: Bool, after expectation: XCTestExpectation) {
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(condition)
    }

    func testRepositoryStartsWithDefault() {
        let options = repository.options
        XCTAssertEqual(options.baseCurrency, .defaultCurrency)
        XCTAssertTrue(options.favorites.isEmpty)
    }

    func testSetBaseCurrency() {
        let currency = fakeCurrency
        repository.setBaseCurrency(currency)
        XCTAssertEqual(repository.options.baseCurrency, currency)
    }

    func testAddFavorite() {
        let currency = fakeCurrency
        repository.addFavorite(currency: currency)
        XCTAssertTrue(repository.options.favorites.contains(currency))
    }

    func testRemoveFavorite() {
        let currency = fakeCurrency
        repository.addFavorite(currency: currency)
        repository.removeFavorite(currency: currency)
        XCTAssertTrue(repository.options.favorites.isEmpty)
    }

    func testPublisherForBaseCurrency() {
        let currency = fakeCurrency
        var publishedCurrency: Currency?
        let expectation = expectation
        subscription = repository.optionsPublisher.sink {
            publishedCurrency = $0.baseCurrency
            expectation.fulfill()
        }
        repository.setBaseCurrency(currency)
        assertTrue(currency == publishedCurrency, after: expectation)
    }

    func testPublisherForAddFavorite() {
        let currency = fakeCurrency
        var publishedFavorites: [Currency]?
        let expectation = expectation
        subscription = repository.optionsPublisher.sink {
            publishedFavorites = $0.favorites
            expectation.fulfill()
        }
        repository.addFavorite(currency: currency)
        assertTrue([currency] == publishedFavorites, after: expectation)
    }

    func testPublisherForRemoveFavorite() {
        let currency = fakeCurrency
        storeOptions(Options(baseCurrency: .defaultCurrency, favorites: [currency]))
        var publishedFavorites: [Currency]?
        let expectation = expectation
        subscription = repository.optionsPublisher.sink {
            publishedFavorites = $0.favorites
            expectation.fulfill()
        }
        repository.removeFavorite(currency: currency)
        assertTrue(publishedFavorites!.isEmpty, after: expectation)
    }
}
