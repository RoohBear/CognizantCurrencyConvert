//
//  CurrencyConverterInteractor.swift
//  CognizantCurrencyDemo
//
//  Created by Shinoy Joseph on 2022-03-24.
//

import Foundation
import Combine

/// Type responsible for receiving an input, perform an operation using that input and comunicating the output of that operation.
protocol CurrencyConverterInteractorProtocol {
    func currencyList() -> AnyPublisher<[Currency], Never>
    func convertionRate(for currency: String,
                        from baseCurrency: String,
                        amount: String) -> AnyPublisher<ConvertData?, Never>
}

/// Type responsible to obtain the currency conversion related values.
class CurrencyConverterInteractor: CurrencyConverterInteractorProtocol {
    private let currencyScoopService: CurrencyScoopServiceProtocol
    
    required init(service: CurrencyScoopServiceProtocol) {
        self.currencyScoopService = service
    }
    
    func currencyList() -> AnyPublisher<[Currency], Never> {
        currencyScoopService.getCurrencies()
            .replaceNil(with: [Currency.defaultCurrency])
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func convertionRate(for currency: String,
                        from baseCurrency: String,
                        amount: String) -> AnyPublisher<ConvertData?, Never> {
        currencyScoopService.convertCurrency(from: currency,
                                             to: baseCurrency,
                                             amount: amount)
        
    }
}
