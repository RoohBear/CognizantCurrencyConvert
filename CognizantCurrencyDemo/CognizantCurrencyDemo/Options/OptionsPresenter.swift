//
//  OptionsPresenter.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/23/22.
//

import Foundation
import Combine

typealias OptionsPresentationData = (options: Options, currencyList: [Currency])

protocol OptionsPresenterProtocol {
    var presentationDataPublisher: AnyPublisher<OptionsPresentationData?, Never> { get }
    func handleDone()
    func handleViewDidLoad()
    func handleFavoriteUpdate(isFavorite: Bool, for currency: Currency)
    func handleBaseCurrencyTap()
}

class OptionsPresenter: OptionsPresenterProtocol {

    var presentationDataPublisher: AnyPublisher<OptionsPresentationData?, Never> {
        presentationDataSubject.eraseToAnyPublisher()
    }
    private lazy var presentationDataSubject = PassthroughSubject<OptionsPresentationData?, Never>()
    private let router: OptionsRouterProtocol
    private let interactor: OptionsInteractorProtocol
    private var selectedCurrencySubscription: AnyCancellable?
    private lazy var subscriptions = Set<AnyCancellable>()
    private var options: Options?
    private var currencyList: [Currency]?

    init(
        router: OptionsRouterProtocol,
        interactor: OptionsInteractorProtocol = OptionsInteractor()
    ) {
        self.router = router
        self.interactor = interactor
    }

    func handleViewDidLoad() {
        interactor.getAllCurrencies().sink { [weak self] in
            self?.handleCurrenciesPublisher(rawCurrencies: $0)
        }.store(in: &subscriptions)

        interactor.optionsPublisher.sink { [weak self] in
            self?.handleOptionsPublisher(options: $0)
        }.store(in: &subscriptions)

        interactor.loadOptionsData()
    }

    func handleFavoriteUpdate(isFavorite: Bool, for currency: Currency) {
        if isFavorite {
            interactor.addFavorite(currency: currency)
        } else {
            interactor.removeFavorite(currency: currency)
        }
    }

    func handleDone() {
        router.dismiss()
    }

    func handleBaseCurrencyTap() {
        selectedCurrencySubscription = router.routeToCurrencyPicker(
            selectedCurrencyCode: (options?.baseCurrency ?? .defaultCurrency).currencyCode
        ).sink { [weak self] in
            self?.interactor.setBaseCurrency($0)
        }
    }

    private func handleCurrenciesPublisher(rawCurrencies: [Currency]?) {
        currencyList = rawCurrencies?.sorted()
        if let currencyList = currencyList, let options = options {
            presentationDataSubject.send((options, currencyList))
        } else {
            presentationDataSubject.send(nil)
        }
    }

    private func handleOptionsPublisher(options: Options) {
        let processedOptions = Options(
            baseCurrency: options.baseCurrency,
            favorites: options.favorites.sorted()
        )
        self.options = processedOptions
        if let currencyList = currencyList {
            presentationDataSubject.send((processedOptions, currencyList))
        }
    }
}
