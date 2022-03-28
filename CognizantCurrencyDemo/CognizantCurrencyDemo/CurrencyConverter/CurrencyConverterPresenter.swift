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
    
    private var currencyList: [String] = []
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
    private func update(exchangeRate: ConvertData) {
        currencyExchangeRatePublisher.send(exchangeRateString(from: exchangeRate))
    }
    
    private func exchangeRateString(from exchangeData: ConvertData) -> String{
        "\(String(format: "%.3f", exchangeData.value)) \(exchangeData.to)"
    }
    
    private func updateCurrecyCodeList(list: [Currency]) {
        currencyList = list.map{ $0.currencyCode }.sorted()
        updateListPublisher.send()
    }
}

// MARK: CurrencyConverterPresenterProtocol Methods
extension CurrencyConverterPresenter {
    func conversionValue() -> String {
        String(exchageRate.value)
    }
    
    func numberCurrencies() -> Int {
        currencyList.count
    }
    
    func currency(at index: Int) -> String {
        currencyList[index]
    }
    
    func viewReady() {
        interactor.currencyList()
            .replaceNil(with: [Currency.defaultCurrency])
            .sink { [weak self] in
                self?.updateCurrecyCodeList(list: $0)
            }.store(in: &cancellables)
    }
    
    func converterCriteriaUpdated(withBaseCurrencyIndex baseCurrencyIndex: Int,
                                  currencyIndex: Int,
                                  amount: String) {
        interactor.conversionRate(for: currencyList[currencyIndex],
                                  from: currencyList[baseCurrencyIndex],
                                  amount: amount)
        .replaceNil(with: ConvertData.defaultConvertData)
        .sink(receiveValue: { [weak self] in
            self?.update(exchangeRate: $0)
        })
        .store(in: &cancellables)
    }
}
