//
//  Currency.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/21/22.
//

import Foundation

struct Currency: Codable, Equatable, Comparable {
    let currencyCode: String
    let currencyName: String

    static func < (lhs: Currency, rhs: Currency) -> Bool {
        lhs.currencyName < rhs.currencyName
    }

    static var defaultCurrency: Currency {
        Currency(currencyCode: "USD", currencyName: "United States dollar")
    }
}

struct FiatCurrencies: Codable {
    let fiats: [String: Currency]
}

struct CurrenciesResponse: Codable {
    let response: FiatCurrencies

    var currencies: [Currency] {
        response.fiats.values.map { $0 }
    }
}
