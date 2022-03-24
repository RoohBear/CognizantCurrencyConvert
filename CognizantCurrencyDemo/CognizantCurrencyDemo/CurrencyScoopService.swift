//
//  CurrencyScoopService.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/21/22.
//

import Foundation
import Combine

protocol CurrencyScoopServiceProtocol {
    func getCurrencies() -> AnyPublisher<[Currency]?, Never>
    func convertCurrency(from: String, to: String, amount: String) -> AnyPublisher<ConvertData?, Never>
}

extension CurrencyScoopServiceProtocol {
    func convertCurrency(from: String, to: String, amount: String){}
}

class CurrencyScoopService: CurrencyScoopServiceProtocol {

    private let networkClient: NetworkClientProtocol

    init(networkClient: NetworkClientProtocol = NetworkClient()) {
        self.networkClient = networkClient
    }

    /// downloads the currencies and returns a publisher of an array of `Currency` objects that never fails
    func getCurrencies() -> AnyPublisher<[Currency]?, Never> {
        networkClient.getData(
            from: EndpointProvider.currenciesEndpoint,  // the URL to call https://api.currencyscoop.com/v1/currencies
            type: CurrenciesResponse.self
        ).map {
            $0?.currencies
        }.eraseToAnyPublisher()                         // causes the output to be an AnyPublisher
    }
    
    /// converts one currency to another and returns a publisher data model`ConvertData
    func convertCurrency(from: String, to: String, amount: String) -> AnyPublisher<ConvertData?, Never> {
        networkClient.getData(
            from: EndpointProvider.convertCurrencyEndpoint(from: from, to: to, amount: amount),
            type: ConvertDataResponse.self
        ).map {
            $0?.response
        }.eraseToAnyPublisher() // causes the output to be an AnyPublisher
    }
}

// response from CurrencyScoop looks like this:
//    {
//        "meta": {
//            "code": 200,
//            "disclaimer": "Usage subject to terms: https://currencyscoop.com/terms"
//        },
//        "response": {
//            "fiats": {
//                "AED": {
//                    "currency_name": "United Arab Emirates dirham",
//                    "currency_code": "AED",
//                    "decimal_units": "2",
//                    "countries": [
//                        "United Arab Emirates"
//                    ]
//                },
//                "AFN": {
//                    "currency_name": "Afghan afghani",
//                    "currency_code": "AFN",
//                    "decimal_units": "2",
//                    "countries": [
//                        "Afghanistan"
//                    ]
//                }
//            }
//        }
//    }


