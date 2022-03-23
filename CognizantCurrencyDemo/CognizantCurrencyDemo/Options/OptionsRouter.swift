//
//  OptionsRouter.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/23/22.
//

import UIKit
import Combine

protocol OptionsRouterProtocol {
    func dismiss()
    func routeToCurrencyPicker(selectedCurrencyCode: String) -> AnyPublisher<Currency, Never>
}

class OptionsRouter: OptionsRouterProtocol {

    private weak var navigationController: UINavigationController!

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.viewControllers = [
            OptionsViewController(presenter: OptionsPresenter(router: self))
        ]
    }

    func routeToCurrencyPicker(selectedCurrencyCode: String) -> AnyPublisher<Currency, Never> {
        let currencyPickerPresenter = CurrencyPickerPresenter(
            title: "Base Currency",
            selectedCurrencyCode: selectedCurrencyCode
        )
        let currencyPickerViewController = CurrencyPickerViewController(
            presenter: currencyPickerPresenter
        )
        navigationController.pushViewController(currencyPickerViewController, animated: true)
        return currencyPickerPresenter.selectedCurrencyPublisher
    }

    func dismiss() {
        navigationController?.dismiss(animated: true)
    }
}
