//
//  FavoritesPresenterTests.swift
//  CognizantCurrencyDemoTests
//
//  Created by Curtis Stilwell on 3/28/22.
//

import XCTest
import Combine
@testable import CognizantCurrencyDemo

class FavoritesPresenterTests: XCTestCase {
    private var mockService: MockService!
    private var mockRepository: MockRepository!
    private var interactor: FavoritesInteractor!
    private var presenter: FavoritesPresenter!
    private var mockRouter: MockFavoritesRouter!
    
    
    override func setUpWithError() throws {
        mockService = MockService()
        mockRepository = MockRepository()
        
        interactor = FavoritesInteractor(
            currencyScoopService: mockService,
            repository: mockRepository)
        
        mockRouter = MockFavoritesRouter()
        
        presenter = FavoritesPresenter(router: mockRouter, interactor: interactor)
    }
    
    override func tearDownWithError() throws {
        mockService = nil
        mockRepository = nil
        interactor = nil
        presenter = nil
        mockRouter = nil
    }
    
    
    func testGetOptionsPublisher_WhenMethodIsCalled_ShouldReturnNonNilOptionsPublisher()  {
        XCTAssertNotNil(presenter.favoriteListPublisher.eraseToAnyPublisher)
    }
    
    func testGetOptions_WhenMethodIsCalled_ShouldReturnRepoOptions()  {
        XCTAssertEqual(presenter.getOptions(), mockRepository.options)
    }
    
    
    func testGetCurrencyRatePublisher_WhenMethodReceivesOptions_ShouldReturnCurrencyRates()  {
        let mockCurrencyRates = CurrencyRates(base: "USD", rates: [ "GBP" : 1.459322 ])
        mockService.mockCurrencyRates = mockCurrencyRates
        
        var currencyRates: CurrencyRates?
        
        let expectation = expectation(description: "wait for publisher")
        
        _ = presenter.currencyRatesPublisher(options: interactor.getOptions()).sink
        {
            currencyRates = $0
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(currencyRates, mockCurrencyRates)
    }
    
    func testShowOptionMenu_WhenMethodIsCalled_ShouldCallRouterShowOptionMenu() {
        presenter.showOptionMenu()
        
        XCTAssertTrue(mockRouter.routeToOptionsGotCalled)
    }
    
    fileprivate class MockFavoritesRouter: FavoritesRouterProtocol {
        var routeToOptionsGotCalled = false
        
        func routeToOptions() {
            routeToOptionsGotCalled = true
        }
        
    }
    
    fileprivate class MockService: CurrencyScoopServiceProtocol {
        
        var mockConvertData: ConvertData?
        
        func convertCurrency(from: String, to: String, amount: String) -> AnyPublisher<ConvertData?, Never> {
            Just(mockConvertData).eraseToAnyPublisher()
        }
        
        var mockCurrencyRates: CurrencyRates?
        
        func getCurrencyRates(base: String, latest: [String]) -> AnyPublisher<CurrencyRates?, Never> {
            Just(mockCurrencyRates).eraseToAnyPublisher()
        }
        
        var mockCurrencies: [Currency]?
        
        func getCurrencies() -> AnyPublisher<[Currency]?, Never> {
            Just(mockCurrencies).eraseToAnyPublisher()
        }
    }
    
    fileprivate class MockRepository: OptionsRepositoryProtocol{
        
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
    
}
