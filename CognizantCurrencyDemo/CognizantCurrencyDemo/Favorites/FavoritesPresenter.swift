//
//  FavoritesPresenter.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/23/22.
//

import Foundation
import Combine

protocol FavoritesPresenterProtocol {
    var rateTimeInfo: String { get }
    func showOptionMenu()
    func getOptions() -> Options
    var favoriteListPublisher: AnyPublisher<Options, Never> { get }
    func currencyRatesPublisher(options: Options) -> AnyPublisher<CurrencyRates?, Never>
}

final class FavoritesPresenter: FavoritesPresenterProtocol {
    
    private let router: FavoritesRouterProtocol
    private let interactor: FavoritesInteractorProtocol
    private var lastFetchDate: Date?
    
    var favoriteListPublisher: AnyPublisher<Options, Never> {
        return interactor.getOptionsPublisher()
    }

    var rateTimeInfo: String {
        guard let date = lastFetchDate else {
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .long
        return dateFormatter.string(from: date)
    }
    
    func currencyRatesPublisher(options: Options) -> AnyPublisher<CurrencyRates?, Never>  {
        interactor.getCurrencyRates(options: options).handleEvents(
            receiveOutput: { [weak self] in
                if $0 != nil {
                    self?.lastFetchDate = Date()
                }
            }
        ).eraseToAnyPublisher()
    }
    
    init(router: FavoritesRouterProtocol, interactor: FavoritesInteractorProtocol = FavoritesInteractor()) {
        self.router = router
        self.interactor = interactor
    }
    
    func showOptionMenu() {
        router.routeToOptions()
    }
    
    func getOptions() -> Options {
        interactor.getOptions()
    }
    
}
