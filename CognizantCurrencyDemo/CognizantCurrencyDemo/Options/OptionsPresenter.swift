//
//  OptionsPresenter.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/23/22.
//

import Foundation
import Combine

protocol OptionsPresenterProtocol {
    func handleDone()
    func handleTap()
}

class OptionsPresenter: OptionsPresenterProtocol {

    private let router: OptionsRouterProtocol
    private var selectedCurrencySubscription: AnyCancellable?
    private var baseCurrencyCode = "USD"

    init(router: OptionsRouterProtocol) {
        self.router = router
    }

    func handleDone() {
        router.dismiss()
    }

    func handleTap() {
        selectedCurrencySubscription = router.routeToCurrencyPicker(
            selectedCurrencyCode: baseCurrencyCode
        ).sink { [weak self] in
            self?.baseCurrencyCode = $0.currencyCode
        }
    }
}
