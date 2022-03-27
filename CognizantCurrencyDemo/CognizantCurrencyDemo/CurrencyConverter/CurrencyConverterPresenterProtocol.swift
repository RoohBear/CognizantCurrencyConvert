//
//  CurrencyConverterPresenterProtocol.swift
//  CognizantCurrencyDemo
//
//  Created by Shinoy Joseph on 2022-03-26.
//

import Foundation
import Combine

/// Type defines the presentation logic of currency converter
protocol CurrencyConverterPresenterProtocol {
    var listUpdatePublisher: AnyPublisher<Void, Never> { get }
    var currencyRatePublisher: AnyPublisher<String?, Never> { get }
    
    func viewReady()
    func numberCurrencies() -> Int
    func currencyData(at index: Int) -> String
    func conversionValue() -> String
    func converterCriteriaUpdated(withBaseCurrencyIndex baseCurrencyIndex: Int,
                                  currencyIndex: Int,
                                  amount: String)
}