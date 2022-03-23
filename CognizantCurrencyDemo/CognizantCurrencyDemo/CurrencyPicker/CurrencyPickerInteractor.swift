//
//  CurrencyPickerInteractor.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/23/22.
//

import Foundation
import Combine

protocol CurrencyPickerInteractorProtocol {
    func getAllCurrencies() -> AnyPublisher<[Currency]?, Never>
}

class CurrencyPickerInteractor: CurrencyPickerInteractorProtocol {

    private let currencyScoopService: CurrencyScoopServiceProtocol

    init(currencyScoopService: CurrencyScoopServiceProtocol = CurrencyScoopService()) {
        self.currencyScoopService = currencyScoopService
    }

    func getAllCurrencies() -> AnyPublisher<[Currency]?, Never> {
        currencyScoopService.getCurrencies()
    }
}
