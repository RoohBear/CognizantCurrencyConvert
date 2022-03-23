//
//  FavoritesPresenter.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/23/22.
//

import Foundation

protocol FavoritesPresenterProtocol {
    func handleTap()
}

class FavoritesPresenter: FavoritesPresenterProtocol {

    private let router: FavoritesRouterProtocol

    init(router: FavoritesRouterProtocol) {
        self.router = router
    }

    func handleTap() {
        router.routeToOptions()
    }
}
