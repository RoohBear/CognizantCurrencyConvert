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
    private var cancellable: AnyCancellable!

    override func setUpWithError() throws {
        clientMock = NetworkClientMock()
        service = CurrencyScoopService(networkClient: clientMock)
    }

    override func tearDownWithError() throws {
        service = nil
        clientMock = nil
        cancellable = nil
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
    
    func testConvertCurrency_WhenServiceFail_shouldReturnNil() {
        let expectation = expectation(description: "wait for service")
        var conversionData: ConvertData?
        clientMock.dataResult = nil
        
        cancellable = service.convertCurrency(from: "CAD", to: "USD", amount: "1").sink {
            conversionData = $0
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 8)
        XCTAssertNil(conversionData, "Conversion data should be nil when service not receive no data")
    }
    
    func testConvertCurrency_WhenServiceSucess_shouldReturnConversionData() {
        let expectation = expectation(description: "wait for service")
        var conversionData: ConvertData?
        
        clientMock.dataResult = ConvertDataResponse(response: ConvertData.defaultConvertData)
        
        cancellable = service.convertCurrency(from: "CAD", to: "USD", amount: "1").sink {
            conversionData = $0
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 8)
        XCTAssertNotNil(conversionData, "When service sucess conversion data should be returned")
    }
    
    func testConvertCurrency_WhenServiceSucess_shouldReturnRightData() {
        let expectation = expectation(description: "wait for service")
        clientMock.dataResult = ConvertDataResponse(response: ConvertData.defaultConvertData)
        let conversionData = ConvertData.defaultConvertData
        var convertedData: ConvertData?
        
        cancellable = service.convertCurrency(from: "CAD", to: "USD", amount: "1").sink {
            convertedData = $0
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 8)
        XCTAssertEqual(conversionData, convertedData, "Converted data from service should be correct convert data")
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
