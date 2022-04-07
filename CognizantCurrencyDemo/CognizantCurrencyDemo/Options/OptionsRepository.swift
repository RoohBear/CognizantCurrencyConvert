//
//  OptionsRepository.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/24/22.
//

import Foundation
import Combine

protocol OptionsRepositoryProtocol {
    var options: Options { get }
    var optionsPublisher: AnyPublisher<Options, Never> { get }
    func setBaseCurrency(_ currency: Currency)
    func addFavorite(currency: Currency)
    func removeFavorite(currency: Currency)
}

class OptionsRepository: OptionsRepositoryProtocol
{
    var options: Options {
        getStoredOptions() ?? Options(baseCurrency: .defaultCurrency, favorites: [])
    }
    var optionsPublisher: AnyPublisher<Options, Never> {
        Self.optionsSubject.eraseToAnyPublisher()
    }
    private static let optionsSubject = PassthroughSubject<Options, Never>()

    private var storageKey: String { "options.storage.key" }

    func setBaseCurrency(_ currency: Currency) {
        storeOptions(Options(baseCurrency: currency, favorites: options.favorites))
    }

    func addFavorite(currency: Currency) {
        let options = options
        let favorites = options.favorites + [currency]
        storeOptions(
            Options(baseCurrency: options.baseCurrency, favorites: favorites)
        )
    }

    func removeFavorite(currency: Currency) {
        let options = options
        var favorites = options.favorites
        favorites.removeAll { $0 == currency }
        storeOptions(
            Options(baseCurrency: options.baseCurrency, favorites: favorites)
        )
    }

    // called when user adds or removes a favourite
    // an Options object contains a base currency and an array of favourites, as an array of Currency objects
    private func storeOptions(_ options: Options)
    {
        guard let jsonData = try? JSONEncoder().encode(options),
              let jsonString = String(data: jsonData, encoding: .utf8)
        else {
            fatalError("failed to store options")
        }
        UserDefaults.standard.set(jsonString, forKey: storageKey)
        Self.optionsSubject.send(options)
    }

    private func getStoredOptions() -> Options? {
        let jsonString = UserDefaults.standard.string(forKey: storageKey)
        guard let jsonData = jsonString?.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(Options.self, from: jsonData)
    }
}
