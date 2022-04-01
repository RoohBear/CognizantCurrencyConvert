//
//  CurrencyConverterPresenter.swift
//  CognizantCurrencyDemo
//
//  Created by Shinoy Joseph on 2022-03-26.
//

import Foundation
import Combine

// Type implements the currency conversion presentation logic
class CurrencyConverterPresenter: CurrencyConverterPresenterProtocol {
    var listUpdatePublisher: AnyPublisher<Void, Never>
    var currencyRatePublisher: AnyPublisher<String?, Never>
    
    private var currencyList: [Currency] = []
    private var exchageRate: ConvertData = ConvertData.defaultConvertData
    
    private let interactor: CurrencyConverterInteractorProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private var updateListPublisher = PassthroughSubject<Void, Never>()
    private var currencyExchangeRatePublisher = PassthroughSubject<String?, Never>()
    
    // MARK:  Initialisers
    required init(with interactor: CurrencyConverterInteractorProtocol) {
        self.interactor = interactor
        
        listUpdatePublisher = updateListPublisher.eraseToAnyPublisher()
        currencyRatePublisher = currencyExchangeRatePublisher.eraseToAnyPublisher()
    }
}

// MARK: Private Methods
extension CurrencyConverterPresenter {
    // called after ScoopService has returned with a conversion for the user to display.
    private func update(exchangeRate: ConvertData) {
        currencyExchangeRatePublisher.send(exchangeRateString(from: exchangeRate))
    }
    
    private func exchangeRateString(from exchangeData: ConvertData) -> String{
        "\(String(format: "%.3f", exchangeData.value)) \(exchangeData.to)"
    }
    
    private func updateCurrencyCodeList(list: [Currency]) {
        currencyList = list.sorted()
        updateListPublisher.send()
    }
}

// MARK: CurrencyConverterPresenterProtocol Methods
extension CurrencyConverterPresenter {
    func numberCurrencies() -> Int {
        currencyList.count
    }
    
    func currencyCode(at index: Int) -> String {
        if currencyList.count < 1 {
            return ""
        }
        
        return currencyList[index].currencyCode
    }
    
    func currencyName(at index: Int) -> String {
        if currencyList.count < 1 {
            return ""
        }
        
        return currencyList[index].currencyName
    }

    func viewReady() {
        interactor.currencyList()
            .replaceNil(with: [Currency.defaultCurrency])
            .sink { [weak self] in
                self?.updateCurrencyCodeList(list: $0)
            }.store(in: &cancellables)
    }
    
    // called by a view controller when the user has updated the UI and we need to do a currency conversion
    func converterCriteriaUpdated(withBaseCurrencyIndex baseCurrencyIndex: Int,         // index of base currency to convert TO
                                  currencyIndex: Int,                                   // currency to convert FROM
                                  amount: String) {                                     // the amount the user wants to convert
        interactor.conversionRate(for: currencyList[currencyIndex].currencyCode,        // currency to convert TO (ie "USD")
                                  from: currencyList[baseCurrencyIndex].currencyCode,   // currency to convert FROM (ie "CAD")
                                  amount: amount)                                       // the amount to convert
        .replaceNil(with: ConvertData.defaultConvertData)                               // if `for` or `from` are nil, replace them with "USD"
        .sink(receiveValue: { [weak self] in                                            // this calls interactor.conversionRate()
            self?.update(exchangeRate: $0)                                              // $0 is a ConvertData object. $0.to is destination currency string, $0.value is the result of the API call. Call self.update() with the result
        })
        .store(in: &cancellables)                                                       // store the result in self.cancellables because
    }
}
