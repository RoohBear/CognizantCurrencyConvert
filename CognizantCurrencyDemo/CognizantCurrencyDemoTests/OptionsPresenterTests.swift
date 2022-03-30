//
//  OptionsPresenterTests.swift
//  CognizantCurrencyDemoTests
//
//  Created by Ben Balcomb on 3/25/22.
//

import XCTest
import Combine
@testable import CognizantCurrencyDemo

class OptionsPresenterTests: XCTestCase {

    private var presenter: OptionsPresenter!
    private var mockRouter: MockRouter!
    private var mockInteractor: MockInteractor!
    private var subscription: AnyCancellable?
    private lazy var expectation: XCTestExpectation! = expectation(description: "wait on publisher")

    private var fakeCurrencies: [Currency] {
        let timestamp = Date().timeIntervalSince1970
        return (0...2).map {
            let suffix = String(timestamp) + String($0)
            return Currency(
                currencyCode: "code" + suffix,
                currencyName: "name" + suffix
            )
        }
    }

    override func setUpWithError() throws {
        mockRouter = MockRouter()
        mockInteractor = MockInteractor()
        presenter = OptionsPresenter(router: mockRouter, interactor: mockInteractor)
    }

    override func tearDownWithError() throws {
        mockRouter = nil
        mockInteractor = nil
        presenter = nil
        subscription = nil
        expectation = nil
    }

    func testInitialData() throws {
        let fakeCurrencies = fakeCurrencies
        mockInteractor.options = Options(
            baseCurrency: fakeCurrencies[0],
            favorites: [fakeCurrencies[1]]
        )
        mockInteractor.currencies = [fakeCurrencies[2]]
        var state: OptionsState?
        subscription = presenter.statePublisher.sink {
            state = $0
            guard state != nil else { return }
            self.expectation.fulfill()
        }
        presenter.processAction(.viewReady)
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(state?.options.baseCurrency, fakeCurrencies[0])
        XCTAssertEqual(state?.options.favorites, [fakeCurrencies[1]])
        XCTAssertEqual(state?.allCurrencies, [fakeCurrencies[2]])
    }

    func testAddFavorite() {
        presenter.processAction(.viewReady)
        let fakeCurrency = fakeCurrencies[0]
        var state: OptionsState?
        subscription = presenter.statePublisher.sink {
            state = $0
            guard state != nil else { return }
            self.expectation.fulfill()
        }
        presenter.processAction(.favoriteUpdate(isFavorite: true, currency: fakeCurrency))
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(state?.options.favorites.contains(fakeCurrency) == true)
    }

    func testRemoveFavorite() {
        presenter.processAction(.viewReady)
        let fakeCurrency = fakeCurrencies[0]
        mockInteractor.options = Options(baseCurrency: .defaultCurrency, favorites: [fakeCurrency])
        var state: OptionsState?
        subscription = presenter.statePublisher.sink {
            state = $0
            guard state != nil else { return }
            self.expectation.fulfill()
        }
        presenter.processAction(.favoriteUpdate(isFavorite: false, currency: fakeCurrency))
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(state?.options.favorites.isEmpty == true)
    }

    func testDismiss() {
        presenter.processAction(.doneButton)
        XCTAssertTrue(mockRouter.didDismiss)
    }

    func testNewBaseCurrency() {
        presenter.processAction(.viewReady)
        var state: OptionsState?
        subscription = presenter.statePublisher.sink {
            state = $0
            guard state != nil else { return }
            self.expectation.fulfill()
        }
        presenter.processAction(.baseCurrencyTap)
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(state?.options.baseCurrency, mockRouter.fakeBaseCurrency)
    }
}

fileprivate class MockRouter: OptionsRouterProtocol {

    var didDismiss = false
    var fakeBaseCurrency: Currency { Currency(currencyCode: "000", currencyName: "new name") }

    func dismiss() {
        didDismiss = true
    }

    func routeToCurrencyPicker(selectedCurrencyCode: String) -> AnyPublisher<Currency, Never> {
        Just(fakeBaseCurrency).eraseToAnyPublisher()
    }
}

fileprivate class MockInteractor: OptionsInteractorProtocol {

    var options = Options(baseCurrency: .defaultCurrency, favorites: [])
    var currencies = [Currency(currencyCode: "XXX", currencyName: "fake name")]

    var optionsPublisher: AnyPublisher<Options, Never> {
        optionsSubject.eraseToAnyPublisher()
    }
    private lazy var optionsSubject = PassthroughSubject<Options, Never>()

    func getAllCurrencies() -> AnyPublisher<[Currency]?, Never> {
        Just(currencies).eraseToAnyPublisher()
    }

    func loadOptionsData() {
        optionsSubject.send(options)
    }

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
        options = Options(
            baseCurrency: options.baseCurrency,
            favorites: options.favorites.filter { $0 != currency }
        )
        optionsSubject.send(options)
    }
}
