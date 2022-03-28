//
//  CurrencyRates.swift
//  CognizantCurrencyDemo
//
//  Created by Curtis Stilwell on 3/25/22.
//

import Foundation

struct CurrencyRatesResponse: Codable {
    let response: CurrencyRates
}

struct CurrencyRates: Codable, Equatable {
    let base: String
    let rates: [String: Double?]
}
