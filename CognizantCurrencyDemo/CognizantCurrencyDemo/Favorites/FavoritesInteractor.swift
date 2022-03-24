//
//  FavoritesInteractor.swift
//  CognizantCurrencyDemo
//
//  Created by Curtis Stilwell on 3/24/22.
//

import Foundation
import Combine

protocol FavoriteInteractorProtocol {
    func getOptionsData() -> AnyPublisher<Options, Never>
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
    
    func getOptionsData() -> AnyPublisher<Options, Never> {
         repository.optionsPublisher
    }
}
