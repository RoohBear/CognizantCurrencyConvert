//
//  EndpointProvider.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/21/22.
//

import Foundation

// class containing functions that supply the URLs for CurrencyScoop.com
class EndpointProvider {

    /// computed variable that returns the URL for getting all the currencies
    /// (should return something like "https://api.currencyscoop.com/v1/currencies?api_key=f447...ddfe&type=fiat")
    static var currenciesEndpoint: URL {
        endpoint(
            with: "currencies",
            queryItems: [URLQueryItem(name: "type", value: "fiat")]
        )
    }
    
    static func latestEndpoint(base: String, latest: [String]) -> URL {
        let latestString = latest.joined(separator:",")
        
       return endpoint(
            with: "latest",
            queryItems:   [URLQueryItem(name: "base", value: base)
                         ,URLQueryItem(name: "symbols", value: latestString)]
        )
    }
    
    /// Returns the currency conversion URL from the currecy, base currency and amounts provided as parameter
    /// - Parameters:
    ///   - from: String represents the currency for getting the conversion rate
    ///   - to: String represents the base currency from which the currency value calculated
    ///   - amount: Double represents the amount
    /// - Returns: URL for the API with the required parameters
    static func convertCurrencyEndpoint(from: String, to: String, amount: String) -> URL {
        endpoint(
            with: "convert",
            queryItems: [URLQueryItem(name: "from", value: from)
                        ,URLQueryItem(name: "to", value: to)
                        ,URLQueryItem(name: "amount", value: amount)]
        )
    }

    /// private helper function for building URLs for CurrencyScoop.com
    /// - Parameters:
    ///   - path: the API name
    ///   - queryItems: the
    /// - Returns: URL for the API requested
    private static func endpoint(with path: String, queryItems: [URLQueryItem]) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.currencyscoop.com"
        components.path = "/v1/" + path
        let apiKeyQueryItem = URLQueryItem(
            name: "api_key",
            value: ProcessInfo.processInfo.environment["CURRENCY_SCOOP_API_KEY"] // see https://www.swiftdevjournal.com/using-environment-variables-in-swift-apps/ for setting this
        )
        components.queryItems = [apiKeyQueryItem] + queryItems
        guard let url = components.url else {
            fatalError()
        }
        return url
    }
}
