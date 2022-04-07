//
//  CurrencyConverterPresenterProtocol.swift
//  CognizantCurrencyDemo
//
//  Created by Shinoy Joseph on 2022-03-26.
//

import Foundation
import Combine

/// Type defines the presentation logic of currency converter
protocol CurrencyConverterPresenterProtocol
{
    var listUpdatePublisher: AnyPublisher<Void, Never> { get }
    var currencyRatePublisher: AnyPublisher<String?, Never> { get }
    var filterFavourites:Bool { get set }    // false=return all currencies, true=return only favourite currencies
    var favouriteCurrencies:[Currency] { get set }

    func viewReady()
    func numberCurrencies() -> Int
    func currencyCode(at index: Int) -> String
    func currencyName(at index: Int) -> String
    func converterCriteriaUpdated(withBaseCurrencyIndex baseCurrencyIndex: Int,
                                  currencyIndex: Int,
                                  amount: String)
}
