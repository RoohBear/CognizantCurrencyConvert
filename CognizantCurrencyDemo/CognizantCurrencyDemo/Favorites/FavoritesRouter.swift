//
//  FavoritesRouter.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/23/22.
//

import UIKit

protocol FavoritesRouterProtocol {
    func routeToOptions()
}

class FavoritesRouter: FavoritesRouterProtocol {

    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.viewControllers = [
            FavoritesViewController(presenter: FavoritesPresenter(router: self))
        ]
    }

    func routeToOptions() {
        let modalNavController = UINavigationController()
        _ = OptionsRouter(navigationController: modalNavController)
        navigationController?.present(modalNavController, animated: true)
    }
}
