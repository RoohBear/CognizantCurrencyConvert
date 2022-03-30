//
//  CurrencyConverterPresenterTests.swift
//  CognizantCurrencyDemoTests
//
//  Created by Shinoy Joseph on 2022-03-28.
//

import XCTest
import Combine
@testable import CognizantCurrencyDemo

class CurrencyConverterPresenterTests: XCTestCase {
    private var mockInteractor: MockInteractor!
    private var presenter: CurrencyConverterPresenter!
    private var expectation: XCTestExpectation!
    private var cancellable: AnyCancellable!
    
    override func setUpWithError() throws {
        mockInteractor = MockInteractor()
        presenter = CurrencyConverterPresenter(with: mockInteractor)
        expectation = expectation(description: "wait for publisher")
    }
    
    override func tearDownWithError() throws {
        mockInteractor = nil
        presenter = nil
        expectation = nil
        cancellable = nil
    }
    
    private func exptectationWait() {
        wait(for: [expectation], timeout: 8)
    }
    
    func testViewReady_WhenCalled_CurrencyListPublisherShouldCalled() {
        var listUpdateCalled = false
        cancellable = presenter.listUpdatePublisher.sink {
            listUpdateCalled = true
            
            self.expectation.fulfill()
        }
        
        presenter.viewReady()
        
        exptectationWait()
        XCTAssertTrue(listUpdateCalled, "When view ready called list update called should be called")
    }
    
    func testConversionValue_WhenCalled_ShouldHaveCurrecyList() {
        let currencyCount = 0
        mockInteractor.mockCurrencies =  [Currency.defaultCurrency]
        cancellable = presenter.listUpdatePublisher.sink {
            self.expectation.fulfill()
        }
        
        presenter.viewReady()
        exptectationWait()
        
        XCTAssertGreaterThan(presenter.numberCurrencies(),
                             currencyCount,
                             "Currency list should be updated when view ready method")
    }
    
    func testNumberOfCurrencies_WhenCalled_CorrectNumberItemShouldReturn() {
        let mockCurrencies = [Currency.defaultCurrency]
        mockInteractor.mockCurrencies = mockCurrencies
        cancellable = presenter.listUpdatePublisher.sink {
            self.expectation.fulfill()
        }
        
        presenter.viewReady()
        exptectationWait()
        
        XCTAssertEqual(presenter.numberCurrencies(),
                       mockCurrencies.count,
                       "When currency count called right number of currency should return")
    }
    
    func testNumberOfCurrencies_WhenServiceFails_ShouldReturnDefaultNumber() {
        let defaultModelCount = 1
        mockInteractor.mockCurrencies =  nil
        cancellable = presenter.listUpdatePublisher.sink {
            self.expectation.fulfill()
        }
        
        presenter.viewReady()
        exptectationWait()
        
        XCTAssertEqual(presenter.numberCurrencies(),
                       defaultModelCount,
                       "Number of  currencies should be one as there will be only default model")
    }
    
    func testNumberOfCurrencies_whenServiceSuccess_ShouldReturnRightNumberOfCurrencies() {
        let mockCurrencyModels = [Currency.defaultCurrency, Currency.defaultCurrency]
        mockInteractor.mockCurrencies =  mockCurrencyModels
        cancellable = presenter.listUpdatePublisher.sink {
            self.expectation.fulfill()
        }
        
        presenter.viewReady()
        exptectationWait()
        
        XCTAssertEqual(presenter.numberCurrencies(),
                       mockCurrencyModels.count,
                       "Number of  currencies should return right number of currency recieved from service")
    }
    
    func testCurrencyAtIndex_WhenRequested_shouldReturnCurrency() {
        let mockCurrencyModel = [Currency.defaultCurrency, Currency.defaultCurrency]
        let currency = mockCurrencyModel[0].currencyCode
        mockInteractor.mockCurrencies =  mockCurrencyModel
        cancellable = presenter.listUpdatePublisher.sink {
            self.expectation.fulfill()
        }
        
        presenter.viewReady()
        exptectationWait()
        
        XCTAssertEqual(presenter.currency(at: 0),
                       currency,
                       "Should return currency code when have value from the service")
    }
    
    func testCurrencyAtIndex_WhenRequested_shouldReturnNil() {
        let emptyString = ""
        mockInteractor.mockCurrencies =  []
        cancellable = presenter.listUpdatePublisher.sink {
            self.expectation.fulfill()
        }
        
        presenter.viewReady()
        exptectationWait()
        
        XCTAssertEqual(presenter.currency(at: 1),
                       emptyString,
                       "Should return empty string when no data available")
    }
    
    func testCurrencyCriteriaUpdated_WhenSendingValues_CurrencyRatePublisherShouldSendMessege() {
        var currencyResponseGetCalled = false
        let mockCurrencyModel = [Currency.defaultCurrency, Currency.defaultCurrency]
        mockInteractor.mockCurrencies = mockCurrencyModel
        cancellable = presenter.currencyRatePublisher.sink {_ in
            currencyResponseGetCalled = true
            
            self.expectation.fulfill()
        }
        
        presenter.viewReady()
        presenter.converterCriteriaUpdated(withBaseCurrencyIndex: 1,
                                                         currencyIndex: 1, amount: "1")
        exptectationWait()
        
        XCTAssertTrue(currencyResponseGetCalled,
                      "When currency criteria updated called, cureenc rate publisher should send messege")
    }
    
    func testCurrencyCriteriaUpdated_WhenSendingValues_CurrencyRatePublisherShouldReturn() {
        var currencyResponseGetCalled = false
        let mockCurrencyModel = [Currency.defaultCurrency, Currency.defaultCurrency]
        mockInteractor.mockCurrencies = mockCurrencyModel
        cancellable = presenter.currencyRatePublisher.sink {_ in
            currencyResponseGetCalled = true
            
            self.expectation.fulfill()
        }
        
        presenter.viewReady()
        presenter.converterCriteriaUpdated(withBaseCurrencyIndex: 1,
                                                         currencyIndex: 1, amount: "1")
        exptectationWait()
        
        XCTAssertTrue(currencyResponseGetCalled,
                      "When currency criteria updated called, cureenc rate publisher should send messege")
    }
    
}

fileprivate class mockInteractor: CurrencyScoopServiceProtocol {
    var mockCurrencies: [Currency]?
    var mockConvertData: ConvertData?
    var mockCurrencyRates: CurrencyRates?
    
    func getCurrencies() -> AnyPublisher<[Currency]?, Never> {
        Just(mockCurrencies).eraseToAnyPublisher()
    }
    
    func convertCurrency(from: String, to: String, amount: String) -> AnyPublisher<ConvertData?, Never> {
        Just(mockConvertData).eraseToAnyPublisher()
    }
    
    func getCurrencyRates(base: String, latest: [String]) -> AnyPublisher<CurrencyRates?, Never> {
        Just(mockCurrencyRates).eraseToAnyPublisher()
    }
}

fileprivate class MockInteractor: CurrencyConverterInteractorProtocol {
    var mockCurrencies: [Currency]?
    var mockConvertData: ConvertData?
    
    func currencyList() -> AnyPublisher<[Currency]?, Never> {
        Just(mockCurrencies).eraseToAnyPublisher()
    }
    
    func conversionRate(for currency: String,
                        from baseCurrency: String,
                        amount: String) -> AnyPublisher<ConvertData?, Never> {
        Just(mockConvertData).eraseToAnyPublisher()
    }
}
