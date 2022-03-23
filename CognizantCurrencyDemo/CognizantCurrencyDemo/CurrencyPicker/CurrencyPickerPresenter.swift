//
//  CurrencyPickerPresenter.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/23/22.
//

import Foundation
import Combine

protocol CurrencyPickerPresenterProtocol {
    var title: String { get }
    var currencyListPublisher: AnyPublisher<[Currency]?, Never> { get }
    var selectedCurrencyPublisher: AnyPublisher<Currency, Never> { get }
    func handleViewDidLoad()
    func isSelectedCurrency(_ currency: Currency) -> Bool
    func handleSelectedCurrency(_ currency: Currency)
}

class CurrencyPickerPresenter: CurrencyPickerPresenterProtocol {

    let title: String
    private var selectedCurrencyCode: String?
    private let interactor: CurrencyPickerInteractorProtocol
    private var getAllCurrenciesSubscription: AnyCancellable?

    var currencyListPublisher: AnyPublisher<[Currency]?, Never> {
        currencyListSubject.eraseToAnyPublisher()
    }
    private lazy var currencyListSubject = PassthroughSubject<[Currency]?, Never>()

    var selectedCurrencyPublisher: AnyPublisher<Currency, Never> {
        selectedCurrencySubject.eraseToAnyPublisher()
    }
    private lazy var selectedCurrencySubject = PassthroughSubject<Currency, Never>()

    init(
        title: String,
        selectedCurrencyCode: String?,
        interactor: CurrencyPickerInteractorProtocol = CurrencyPickerInteractor()
    ) {
        self.title = title
        self.selectedCurrencyCode = selectedCurrencyCode
        self.interactor = interactor
    }

    func handleViewDidLoad() {
        getAllCurrenciesSubscription = interactor.getAllCurrencies().sink { [weak self] in
            self?.currencyListSubject.send(self?.getCurriencesForDisplay($0))
        }
    }

    func isSelectedCurrency(_ currency: Currency) -> Bool {
        currency.currencyCode == selectedCurrencyCode
    }

    func handleSelectedCurrency(_ currency: Currency) {
        selectedCurrencyCode = currency.currencyCode
        selectedCurrencySubject.send(currency)
    }

    private func getCurriencesForDisplay(_ currencies: [Currency]?) -> [Currency]? {
        var currencies = currencies
        currencies?.sort { $0.currencyName < $1.currencyName }
        if let selectedCurrency = currencies?.first(
            where: { $0.currencyCode == selectedCurrencyCode }
        ) {
            currencies?.removeAll(where: { $0 == selectedCurrency })
            currencies?.insert(selectedCurrency, at: 0)
        }
        return currencies
    }
}
