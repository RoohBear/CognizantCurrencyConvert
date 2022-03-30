//
//  CurrencyConverterInteractorTests.swift
//  CognizantCurrencyDemoTests
//
//  Created by Shinoy Joseph on 2022-03-28.
//

import XCTest
import Combine
@testable import CognizantCurrencyDemo

class CurrencyConverterInteractorTests: XCTestCase {
    private var mockService: MockService!
    private var interactor: CurrencyConverterInteractorProtocol!
    private var expectation: XCTestExpectation!
    private var cancellable: AnyCancellable!
    
    override func setUpWithError() throws {
        mockService = MockService()
        interactor = CurrencyConverterInteractor(service: mockService)
        expectation = expectation(description: "wait for publisher")
    }

    override func tearDownWithError() throws {
        mockService = nil
        interactor = nil
        expectation = nil
        cancellable = nil
    }
    
    private func exptectationWait() {
        wait(for: [expectation], timeout: 8)
    }

    func testCurrencyList_WhenGetNoCurrencies_shouldReturnNil() {
        mockService.mockCurrencies = nil
        var currencyList: [Currency]?
        
        cancellable = interactor.currencyList().sink(receiveValue: { currencies in
            currencyList = currencies
            self.expectation.fulfill()
        })
        exptectationWait()
        
        XCTAssertNil(currencyList, "When service returns nil interactor should return nil")
    }
    
    func testCurrencyList_WhenRecieveCurrencies_shouldGetCurreciesArray() {
        let currencies = [Currency.defaultCurrency]
        mockService.mockCurrencies = [Currency.defaultCurrency]
        var currencyList: [Currency]?
        
        cancellable = interactor.currencyList().sink(receiveValue: { currencies in
            currencyList = currencies
            self.expectation.fulfill()
        })
        exptectationWait()
        
        XCTAssertEqual(currencyList, currencies, "When service is success interactor should return array of currecies")
    }
    
    func testConversionRate_WhenReceiveNoConversion_ShouldReturnNil() {
        mockService.mockConvertData = nil
        var conversionRate: ConvertData?
        
        cancellable = interactor.conversionRate(for: "USD", from: "CAD", amount: "1").sink {
            conversionRate = $0
            self.expectation.fulfill()
        }
        exptectationWait()
        
        XCTAssertNil(conversionRate, "When service returns nil interactor should return nil")
    }
    
    func testConversionRate_WhenReceiveValue_ShouldReturnValidConversionData() {
        let conversionData = ConvertData.defaultConvertData
        mockService.mockConvertData = ConvertData.defaultConvertData
        var conversionRate: ConvertData?
        
        cancellable = interactor.conversionRate(for: "USD", from: "CAD", amount: "1").sink {
            conversionRate = $0
            self.expectation.fulfill()
        }
        exptectationWait()
        
        XCTAssertEqual(conversionRate, conversionData, "When service is successful interactor should recieve conversion data")
    }
}

fileprivate class MockService: CurrencyScoopServiceProtocol {
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
