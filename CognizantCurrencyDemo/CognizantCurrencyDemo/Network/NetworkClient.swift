//
//  NetworkClient.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/21/22.
//

import Foundation
import Combine

protocol NetworkClientProtocol {
    func getData<D: Decodable>(from endpoint: URL, type: D.Type) -> AnyPublisher<D?, Never>
}

class NetworkClient: NetworkClientProtocol {

    func getData<D: Decodable>(from endpoint: URL, type: D.Type) -> AnyPublisher<D?, Never> {
        let dataPublisher = PassthroughSubject<D?, Never>()
        let dataTask = URLSession.shared.dataTask(with: endpoint) { rawData, _, _ in
            var data: D?
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            if let rawData = rawData, let decodedData = try? decoder.decode(D.self, from: rawData) {
                data = decodedData
            }
            dataPublisher.send(data)
        }
        dataTask.resume()
        return dataPublisher.eraseToAnyPublisher()
    }
}
