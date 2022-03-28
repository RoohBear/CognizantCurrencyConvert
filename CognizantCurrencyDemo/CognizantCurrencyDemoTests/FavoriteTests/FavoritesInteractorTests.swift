//
//  FavoritesInteractorTests.swift
//  CognizantCurrencyDemoTests
//
//  Created by Curtis Stilwell on 3/27/22.
//

import XCTest
import Combine
@testable import CognizantCurrencyDemo

class FavoritesInteractorTests: XCTestCase {
    private var mockService: MockService!
    private var mockRepository: MockRepository!
    private var interactor: FavoritesInteractor!
    
    
    override func setUpWithError() throws {
        mockService = MockService()
        mockRepository = MockRepository()
        
        interactor = FavoritesInteractor(
            currencyScoopService: mockService,
            repository: mockRepository)
    }
    
    override func tearDownWithError() throws {
        mockService = nil
        mockRepository = nil
        interactor = nil
    }
    
    
    func testGetOptionsPublisher_WhenMethodIsCalled_ShouldReturnNonNilOptionsPublisher()  {
        XCTAssertNotNil(interactor.getOptionsPublisher().eraseToAnyPublisher())
    }
    
    func testGetOptions_WhenMethodIsCalled_ShouldReturnRepoOptions()  {
        XCTAssertEqual(interactor.getOptions(), mockRepository.options)
    }
    
    func testGetCurrencyRate_WhenMethodReceivesOptions_ShouldReturnCurrencyRates()  {
        
        let mockCurrencyRates = CurrencyRates(base: "USD", rates: [ "GBP" : 1.459322 ])
        mockService.mockCurrencyRates = mockCurrencyRates
        
        var currencyRates: CurrencyRates?
        
        let expectation = expectation(description: "wait for publisher")
        
        _ = interactor.getCurrencyRates(options: interactor.getOptions()).sink
        {
            currencyRates = $0
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(currencyRates, mockCurrencyRates)
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
