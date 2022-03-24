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
    
    
    func convertCurrency(from: String, to: String, amount: String) -> AnyPublisher<ConvertData?, Never> {
        currencyScoopService.convertCurrency(from: from, to: to, amount: amount)
    }
    
    func getOptionsPublisher() -> AnyPublisher<Options, Never> {
         repository.optionsPublisher
    }
    
    func getOptions() -> Options {
        repository.options
    }
}
