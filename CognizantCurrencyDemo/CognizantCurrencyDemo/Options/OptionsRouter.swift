//
//  OptionsRouter.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/23/22.
//

import UIKit

protocol OptionsRouterProtocol {
    func dismiss()
    func routeToCurrencyPicker()
}

class OptionsRouter: OptionsRouterProtocol {

    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.viewControllers = [
            OptionsViewController(presenter: OptionsPresenter(router: self))
        ]
    }

    func routeToCurrencyPicker() {
        print("routeToCurrencyPicker")
    }

    func dismiss() {
        navigationController?.dismiss(animated: true)
    }
}
