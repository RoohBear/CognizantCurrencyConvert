//
//  OptionsInteractorTests.swift
//  CognizantCurrencyDemoTests
//
//  Created by Ben Balcomb on 3/23/22.
//

import XCTest
import Combine
@testable import CognizantCurrencyDemo

class OptionsInteractorTests: XCTestCase {

    private var mockService: MockService!
    private var mockRepository: MockRepository!
    private var interactor: OptionsInteractor!
    private var subscription: AnyCancellable?
    private var expectation: XCTestExpectation!
    private var fakeCurrencies: (Currency, Currency)!

    override func setUpWithError() throws {
        mockService = MockService()
        mockRepository = MockRepository()
        interactor = OptionsInteractor(
            currencyScoopService: mockService,
            repository: mockRepository
        )
        expectation = expectation(description: "wait for publisher")
        let timestamp = String(Date().timeIntervalSince1970)
        let strings = Array(0...3).map { timestamp + String($0) }
        fakeCurrencies = (
            Currency(currencyCode: strings[0], currencyName: strings[1]),
            Currency(currencyCode: strings[2], currencyName: strings[3])
        )
    }

    override func tearDownWithError() throws {
        mockService = nil
        mockRepository = nil
        interactor = nil
        expectation = nil
        fakeCurrencies = nil
    }

    private func waitForPublisher() {
        wait(for: [expectation], timeout: 9)
    }

    private func makeOptionsWith(favorite: Currency) -> Options {
        Options(baseCurrency: .defaultCurrency, favorites: [favorite])
    }

    func testOptionsStartWithDefaultCurrency() throws {
        var options: Options?
        subscription = interactor.optionsPublisher.sink {
            options = $0
            self.expectation.fulfill()
        }
        interactor.loadOptionsData()
        waitForPublisher()
        XCTAssertEqual(options?.baseCurrency, .defaultCurrency)
    }

    func testOptionsStartWithEmptyFavorites() throws {
        var options: Options?
        subscription = interactor.optionsPublisher.sink {
            options = $0
            self.expectation.fulfill()
        }
        interactor.loadOptionsData()
        waitForPublisher()
        XCTAssertTrue(options?.favorites.isEmpty == true)
    }

    func testSetBaseCurrency() {
        var options: Options?
        subscription = interactor.optionsPublisher.sink {
            options = $0
            self.expectation.fulfill()
        }
        DispatchQueue.main.async {
            self.interactor.setBaseCurrency(self.fakeCurrencies.0)
        }
        waitForPublisher()
        XCTAssertEqual(options?.baseCurrency, fakeCurrencies.0)
    }

    func testAddFavorite() {
        var options: Options?
        subscription = interactor.optionsPublisher.sink {
            options = $0
            self.expectation.fulfill()
        }
        DispatchQueue.main.async {
            self.interactor.addFavorite(currency: self.fakeCurrencies.0)
        }
        waitForPublisher()
        XCTAssertEqual(options?.favorites, [fakeCurrencies.0])
    }

    func testAddFavoriteDuplicatesNotStored() {
        var options: Options?
        subscription = interactor.optionsPublisher.sink {
            options = $0
            self.expectation.fulfill()
        }
        mockRepository.options = makeOptionsWith(favorite: fakeCurrencies.0)
        DispatchQueue.main.async {
            self.interactor.addFavorite(currency: self.fakeCurrencies.0)
            self.interactor.addFavorite(currency: self.fakeCurrencies.1)
        }
        waitForPublisher()
        XCTAssertEqual(options?.favorites, [fakeCurrencies.0, fakeCurrencies.1])
    }

    func testRemoveFavorite() {
        var options: Options?
        subscription = interactor.optionsPublisher.sink {
            options = $0
            self.expectation.fulfill()
        }
        mockRepository.options = makeOptionsWith(favorite: fakeCurrencies.0)
        DispatchQueue.main.async {
            self.interactor.removeFavorite(currency: self.fakeCurrencies.0)
        }
        waitForPublisher()
        XCTAssertTrue(options?.favorites.isEmpty == true)
    }

    func testRemoveFavoriteWithNonfavorite() {
        var options: Options?
        subscription = interactor.optionsPublisher.sink {
            options = $0
            self.expectation.fulfill()
        }
        mockRepository.options = makeOptionsWith(favorite: fakeCurrencies.0)
        DispatchQueue.main.async {
            self.interactor.removeFavorite(currency: self.fakeCurrencies.1)
            self.interactor.loadOptionsData()
        }
        waitForPublisher()
        XCTAssertEqual(options?.favorites, [fakeCurrencies.0])
    }

    func testGetCurrencies() {
        let mockCurrencies = [fakeCurrencies.0, fakeCurrencies.1].shuffled()
        mockService.mockCurrencies = mockCurrencies
        var currencies: [Currency]? = []
        subscription = interactor.getAllCurrencies().sink {
            currencies = $0
            self.expectation.fulfill()
        }
        waitForPublisher()
        XCTAssertEqual(currencies, mockCurrencies)
    }
}

fileprivate class MockService: CurrencyScoopServiceProtocol {

    var mockCurrencies: [Currency]?

    func getCurrencies() -> AnyPublisher<[Currency]?, Never> {
        Just(mockCurrencies).eraseToAnyPublisher()
    }
}

fileprivate class MockRepository: OptionsRepositoryProtocol {

    var options: Options = Options(baseCurrency: .defaultCurrency, favorites: [])

    var optionsPublisher: AnyPublisher<Options, Never> { optionsSubject.eraseToAnyPublisher() }
    private lazy var optionsSubject = PassthroughSubject<Options, Never>()

    func setBaseCurrency(_ currency: Currency) {
        options = Options(baseCurrency: currency, favorites: options.favorites)
        optionsSubject.send(options)
    }

    func addFavorite(currency: Currency) {
        options = Options(
            baseCurrency: options.baseCurrency,
            favorites: options.favorites + [currency]
        )
        optionsSubject.send(options)
    }

    func removeFavorite(currency: Currency) {
        var favorites = options.favorites
        favorites.removeAll { $0 == currency }
        options = Options(baseCurrency: options.baseCurrency, favorites: favorites)
        optionsSubject.send(options)
    }
}
