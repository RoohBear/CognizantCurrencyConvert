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
    var favoriteListPublisher: AnyPublisher<Options, Never> { get }
}

final class FavoritesPresenter: FavoritesPresenterProtocol {
    
    private let router: FavoritesRouterProtocol
    private let interactor: FavoriteInteractorProtocol
    private var getFavoriteListSubscription: AnyCancellable?
    
    private lazy var favoriteListSubject = PassthroughSubject<Options?, Never>()
    
    var favoriteListPublisher: AnyPublisher<Options, Never> {
        return interactor.getOptionsData()
    }
    
    init(router: FavoritesRouterProtocol, interactor: FavoriteInteractorProtocol = FavoriteInteractor()) {
        self.router = router
        self.interactor = interactor
    }
    
    func showOptionMenu() {
        router.routeToOptions()
    }
    
    
}
