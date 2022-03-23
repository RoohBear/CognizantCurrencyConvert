//
//  EndpointProvider.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/21/22.
//

import Foundation

class EndpointProvider {

    static var currenciesEndpoint: URL {
        endpoint(
            with: "currencies",
            queryItems: [URLQueryItem(name: "type", value: "fiat")]
        )
    }

    private static func endpoint(with path: String, queryItems: [URLQueryItem]) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.currencyscoop.com"
        components.path = "/v1/" + path
        let apiKeyQueryItem = URLQueryItem(
            name: "api_key",
            value: ProcessInfo.processInfo.environment["CURRENCY_SCOOP_API_KEY"]
        )
        components.queryItems = [apiKeyQueryItem] + queryItems
        guard let url = components.url else {
            fatalError()
        }
        return url
    }
}
