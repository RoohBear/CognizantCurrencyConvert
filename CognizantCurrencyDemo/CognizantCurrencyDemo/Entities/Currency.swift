//
//  Currency.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/21/22.
//

import Foundation

struct Currency: Codable, Equatable {
    let currencyCode: String
    let currencyName: String
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
