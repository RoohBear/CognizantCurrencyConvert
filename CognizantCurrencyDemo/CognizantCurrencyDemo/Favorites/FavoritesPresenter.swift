//
//  FavoritesPresenter.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/23/22.
//

import Foundation
import Combine

protocol FavoritesPresenterProtocol {
    func showOptionMenu()
    func getOptions() -> Options
    var favoriteListPublisher: AnyPublisher<Options, Never> { get }
    func currencyRatesPublisher(options: Options) -> AnyPublisher<CurrencyRates?, Never>
}

final class FavoritesPresenter: FavoritesPresenterProtocol {
    
    private let router: FavoritesRouterProtocol
    private let interactor: FavoritesInteractorProtocol
    
    init(router: FavoritesRouterProtocol, interactor: FavoritesInteractorProtocol = FavoritesInteractor()) {
        self.router = router
        self.interactor = interactor
    }
    
    var favoriteListPublisher: AnyPublisher<Options, Never> {
        return interactor.getOptionsPublisher()
    }
    
    func currencyRatesPublisher(options: Options) -> AnyPublisher<CurrencyRates?, Never>  {
        interactor.getCurrencyRates(options: options)
    }
    
    func showOptionMenu() {
        router.routeToOptions()
    }
    
    func getOptions() -> Options {
        interactor.getOptions()
    }
    
}
