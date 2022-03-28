//
//  OptionsPresenter.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/23/22.
//

import Foundation
import Combine

enum OptionsAction {
    case viewReady
    case doneButton
    case favoriteUpdate(isFavorite: Bool, currency: Currency)
    case baseCurrencyTap
}

struct OptionsState {
    let options: Options
    let allCurrencies: [Currency]
}

class OptionsPresenter: AnyPresenter<OptionsAction, OptionsState> {

    override var statePublisher: AnyPublisher<State?, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    private lazy var stateSubject = PassthroughSubject<State?, Never>()
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

    override func processAction(_ action: Action) {
        switch action {
        case .viewReady:
            handleViewDidLoad()
        case .doneButton:
            handleDone()
        case .favoriteUpdate(let isFavorite, let currency):
            handleFavoriteUpdate(isFavorite: isFavorite, for: currency)
        case .baseCurrencyTap:
            handleBaseCurrencyTap()
        }
    }

    private func handleViewDidLoad() {
        interactor.optionsPublisher.sink { [weak self] in
            self?.handleOptionsPublisher(options: $0)
        }.store(in: &subscriptions)
        interactor.loadOptionsData()

        interactor.getAllCurrencies().sink { [weak self] in
            self?.handleCurrenciesPublisher(rawCurrencies: $0)
        }.store(in: &subscriptions)
    }

    private func handleFavoriteUpdate(isFavorite: Bool, for currency: Currency) {
        if isFavorite {
            interactor.addFavorite(currency: currency)
        } else {
            interactor.removeFavorite(currency: currency)
        }
    }

    private func handleDone() {
        router.dismiss()
    }

    private func handleBaseCurrencyTap() {
        selectedCurrencySubscription = router.routeToCurrencyPicker(
            selectedCurrencyCode: (options?.baseCurrency ?? .defaultCurrency).currencyCode
        ).sink { [weak self] in
            self?.interactor.setBaseCurrency($0)
        }
    }

    private func handleCurrenciesPublisher(rawCurrencies: [Currency]?) {
        currencyList = rawCurrencies?.sorted()
        if let currencyList = currencyList, let options = options {
            stateSubject.send(State(options: options, allCurrencies: currencyList))
        } else {
            stateSubject.send(nil)
        }
    }

    private func handleOptionsPublisher(options: Options) {
        let processedOptions = Options(
            baseCurrency: options.baseCurrency,
            favorites: options.favorites.sorted()
        )
        self.options = processedOptions
        if let currencyList = currencyList {
            stateSubject.send(State(options: processedOptions, allCurrencies: currencyList))
        }
    }
}
