//
//  OptionsPresenter.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/23/22.
//

import Foundation

protocol OptionsPresenterProtocol {
    func handleDone()
    func handleTap()
}

class OptionsPresenter: OptionsPresenterProtocol {

    private let router: OptionsRouterProtocol

    init(router: OptionsRouterProtocol) {
        self.router = router
    }

    func handleDone() {
        router.dismiss()
    }

    func handleTap() {
        router.routeToCurrencyPicker()
    }
}
