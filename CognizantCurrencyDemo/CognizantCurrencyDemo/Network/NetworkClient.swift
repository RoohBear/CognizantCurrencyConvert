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

// Another way of doing service

//protocol ScoopServiceProtocol {
//    func data<T: Decodable>(from endpoint: URL, output: T.Type) -> AnyPublisher<T?, Error>
//}
//
//class ScoopService: ScoopServiceProtocol {
//    func data<T: Decodable>(from endpoint: URL, output: T.Type) -> AnyPublisher<T?, Error> {
//        return URLSession.shared.dataTaskPublisher(for: endpoint)
//            .map { $0.data }
//            .decode(type: output.self, decoder: JSONDecoder())
//            .map { $0 }
//            .receive(on: RunLoop.main)
//            .eraseToAnyPublisher()
//    }
//}
