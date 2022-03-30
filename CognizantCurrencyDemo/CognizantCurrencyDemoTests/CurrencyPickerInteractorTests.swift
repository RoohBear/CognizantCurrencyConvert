//
//  CurrencyPickerInteractorTests.swift
//  CognizantCurrencyDemoTests
//
//  Created by Greg on 2022-03-30.
//

import XCTest
import Combine
@testable import CognizantCurrencyDemo

class ScoopServiceMock: CurrencyScoopServiceProtocol
{
    func getCurrencies() -> AnyPublisher<[Currency]?, Never> {
        var x = [Currency]()
        x.append(Currency(currencyCode:"greg", currencyName:"greg's fancy currency"))
        return Just(x).eraseToAnyPublisher()
    }
    
    func convertCurrency(from: String, to: String, amount: String) -> AnyPublisher<ConvertData?, Never> {
        return Just(ConvertData(to: "CAD", value: 123.45)).eraseToAnyPublisher()
    }
    
    func getCurrencyRates(base: String, latest: [String]) -> AnyPublisher<CurrencyRates?, Never> {
        return Just(CurrencyRates(base: "USD", rates: ["USD":1.23])).eraseToAnyPublisher()
    }
}

class CurrencyPickerInteractorTests: XCTestCase
{
    var cancellables = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    // same as above, but uses Mocked Scoop Service
    func testCurrencyPickerInteractorMocked()
    {
        let cpi = CurrencyPickerInteractor(currencyScoopService: ScoopServiceMock())
        
        let expectation = expectation(description: "waiting for currency picker interactor")
        let _ = cpi.getAllCurrencies().sink {
            print("got something from scoop service")
            if let x = $0 {
                XCTAssert(x.count > 0)
            }
            expectation.fulfill()
        }.store(in: &cancellables)

        wait(for: [expectation], timeout: 8)
    }
}
