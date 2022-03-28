//
//  CurrencyScoopServiceTests.swift
//  CognizantCurrencyDemoTests
//
//  Created by Ben Balcomb on 3/21/22.
//

import XCTest
import Combine
@testable import CognizantCurrencyDemo

class CurrencyScoopServiceTests: XCTestCase {

    private var clientMock: NetworkClientMock!
    private var service: CurrencyScoopService!

    override func setUpWithError() throws {
        clientMock = NetworkClientMock()
        service = CurrencyScoopService(networkClient: clientMock)
    }

    override func tearDownWithError() throws {
        service = nil
        clientMock = nil
    }
    
    func testGetCurrencyRateEndpoint() {
        _ = service.getCurrencyRates(base: "USD", latest: ["GBP, JPY"])
       
        XCTAssertEqual(clientMock.lastEndpoint, EndpointProvider.latestEndpoint(base: "USD", latest: ["GBP, JPY"]))
    }
    
    func testConvertCurrencyEndpoint() {
        _ = service.convertCurrency(from: "USD", to: "JPY", amount: "3")
       
        XCTAssertEqual(clientMock.lastEndpoint, EndpointProvider.convertCurrencyEndpoint(from: "USD", to: "JPY", amount: "3"))
    }

    func testGetCurrienciesEndpoint() {
        _ = service.getCurrencies()
        XCTAssertEqual(clientMock.lastEndpoint, EndpointProvider.currenciesEndpoint)
    }

    func testGetCurrenciesNil() {
        _ = service.getCurrencies().sink {
            XCTAssertNil($0)
        }
    }

    func testGetCurrenciesEmpty() {
        clientMock.dataResult = CurrenciesResponse(response: FiatCurrencies(fiats: [:]))
        _ = service.getCurrencies().sink {
            XCTAssertTrue($0?.isEmpty == true)
        }
    }

    func testGetCurrenciesValues() {
        var currencyDict = [String: Currency]()
        for num in (0...9) {
            let string = String(num)
            currencyDict[string] = Currency(currencyCode: string, currencyName: string)
        }
        clientMock.dataResult = CurrenciesResponse(response: FiatCurrencies(fiats: currencyDict))
        _ = service.getCurrencies().sink { currencies in
            XCTAssertEqual(currencies?.count, currencyDict.values.count)
            currencyDict.values.forEach { currency in
                XCTAssertTrue(currencies?.contains(currency) == true)
            }
        }
    }
}

fileprivate class NetworkClientMock: NetworkClientProtocol {

    var dataResult: Decodable?
    var lastEndpoint: URL?

    func getData<D: Decodable>(from endpoint: URL, type: D.Type) -> AnyPublisher<D?, Never> {
        lastEndpoint = endpoint
        return Just(dataResult as? D).eraseToAnyPublisher()
    }
}
