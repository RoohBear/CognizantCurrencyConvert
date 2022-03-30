//
//  CurrencyPickerInteractorTests.swift
//  CognizantCurrencyDemoTests
//
//  Created by Shinoy on 2022-03-30.
//

import XCTest
import Combine
@testable import CognizantCurrencyDemo

class CurrencyPickerInteractorTests: XCTestCase
{
    var cancellables = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    // Downloads currencies from CurrencyScoopService.
    // Asserts that the # of currencies downloaded is > 0
    func testCurrencyPickerInteractor()
    {
        let cpi = CurrencyPickerInteractor(currencyScoopService: CurrencyScoopService())
        
        let expectation = expectation(description: "waiting for currency picker interactor")
        let _ = cpi.getAllCurrencies().sink { [weak self] in
            print("got something from scoop service")
            if let x = $0 {
                XCTAssert(x.count > 0)
            }
            expectation.fulfill()
        }.store(in: &cancellables)

        wait(for: [expectation], timeout: 8)
    }
}
