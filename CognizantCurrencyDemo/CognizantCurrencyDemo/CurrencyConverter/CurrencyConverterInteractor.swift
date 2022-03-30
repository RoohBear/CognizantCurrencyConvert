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
    func currencyList() -> AnyPublisher<[Currency]?, Never>
    func conversionRate(for currency: String,
                        from baseCurrency: String,
                        amount: String) -> AnyPublisher<ConvertData?, Never>
}

/// Type responsible to obtain the currency conversion related values.
class CurrencyConverterInteractor: CurrencyConverterInteractorProtocol {
    private let currencyScoopService: CurrencyScoopServiceProtocol
    
    required init(service: CurrencyScoopServiceProtocol) {
        self.currencyScoopService = service
    }
    
    func currencyList() -> AnyPublisher<[Currency]?, Never> {
        currencyScoopService.getCurrencies()
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    // called by a presenter when the user wants to do a currency conversion
    func conversionRate(for currency: String,                                       // destination conversion ("USD")
                        from baseCurrency: String,                                  // source conversion ("CAD")
                        amount: String) -> AnyPublisher<ConvertData?, Never> {      // the amount to convert
        currencyScoopService.convertCurrency(from: currency,                        // call the CurrencyScoopService here.
                                             to: baseCurrency,
                                             amount: amount)
        
    }
}
