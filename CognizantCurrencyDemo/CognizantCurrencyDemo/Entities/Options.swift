//
//  Options.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/24/22.
//

import Foundation

struct Options: Codable {
    let baseCurrency: Currency
    let favorites: [Currency]
}
