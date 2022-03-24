//
//  OptionsInteractor.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/24/22.
//

import Foundation
import Combine

protocol OptionsInteractorProtocol {
    var optionsPublisher: AnyPublisher<Options, Never> { get }
    func getAllCurrencies() -> AnyPublisher<[Currency]?, Never>
    func loadOptionsData()
    func setBaseCurrency(_ currency: Currency)
    func addFavorite(currency: Currency)
    func removeFavorite(currency: Currency)
}

class OptionsInteractor: OptionsInteractorProtocol {

    var optionsPublisher: AnyPublisher<Options, Never> {
        optionsSubject.eraseToAnyPublisher()
    }
    private lazy var optionsSubject = PassthroughSubject<Options, Never>()

    private let currencyScoopService: CurrencyScoopServiceProtocol
    private let repository: OptionsRepositoryProtocol
    private var optionsSubscription: AnyCancellable?

    init(
        currencyScoopService: CurrencyScoopServiceProtocol = CurrencyScoopService(),
        repository: OptionsRepositoryProtocol = OptionsRepository()
    ) {
        self.currencyScoopService = currencyScoopService
        self.repository = repository
        DispatchQueue.main.async {
            self.optionsSubscription = repository.optionsPublisher.sink { [weak self] in
                self?.optionsSubject.send($0)
            }
        }
    }

    func loadOptionsData() {
        optionsSubject.send(repository.options)
    }

    func getAllCurrencies() -> AnyPublisher<[Currency]?, Never> {
        currencyScoopService.getCurrencies()
    }

    func setBaseCurrency(_ currency: Currency) {
        repository.setBaseCurrency(currency)
    }

    func addFavorite(currency: Currency) {
        let options = repository.options
        guard !options.favorites.contains(currency) else { return }
        repository.addFavorite(currency: currency)
    }

    func removeFavorite(currency: Currency) {
        let options = repository.options
        guard options.favorites.contains(currency) else { return }
        repository.removeFavorite(currency: currency)
    }
}
