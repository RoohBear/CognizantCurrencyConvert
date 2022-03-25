//
//  FavoritesInteractor.swift
//  CognizantCurrencyDemo
//
//  Created by Curtis Stilwell on 3/24/22.
//

import Foundation
import Combine

protocol FavoriteInteractorProtocol {
    func getOptionsPublisher() -> AnyPublisher<Options, Never>
    func getOptions() -> Options
    func getCurrencyRates(options: Options) -> AnyPublisher<CurrencyRates?, Never>
}

final class FavoriteInteractor: FavoriteInteractorProtocol {
    private let currencyScoopService: CurrencyScoopServiceProtocol
    private let repository: OptionsRepositoryProtocol
    private lazy var subscriptions = Set<AnyCancellable>()
    
    init(
        currencyScoopService: CurrencyScoopServiceProtocol = CurrencyScoopService(),
        repository: OptionsRepositoryProtocol = OptionsRepository()
    ) {
        self.currencyScoopService = currencyScoopService
        self.repository = repository
    }
  
    func getOptionsPublisher() -> AnyPublisher<Options, Never> {
         repository.optionsPublisher
    }
    
    func getOptions() -> Options {
        repository.options
    }
    
    func getCurrencyRates(options: Options) -> AnyPublisher<CurrencyRates?, Never>  {
        var currencyCodeArray = [String]()
        
        for currency in options.favorites {
            currencyCodeArray.append(currency.currencyCode)
        }
        
        return currencyScoopService.getCurrencyRates(base: options.baseCurrency.currencyCode, latest: currencyCodeArray).eraseToAnyPublisher()
    }
}
