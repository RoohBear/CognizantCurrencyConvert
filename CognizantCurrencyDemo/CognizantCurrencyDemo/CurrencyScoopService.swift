//
//  CurrencyScoopService.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/21/22.
//

import Foundation
import Combine

protocol CurrencyScoopServiceProtocol {
    func getCurrencies() -> AnyPublisher<[Currency]?, Never>
}

class CurrencyScoopService: CurrencyScoopServiceProtocol {

    private let networkClient: NetworkClientProtocol

    init(networkClient: NetworkClientProtocol = NetworkClient()) {
        self.networkClient = networkClient
    }

    func getCurrencies() -> AnyPublisher<[Currency]?, Never> {
        networkClient.getData(
            from: EndpointProvider.currenciesEndpoint,
            type: CurrenciesResponse.self
        ).map {
            $0?.currencies
        }.eraseToAnyPublisher()
    }
}
