//
//  ConvertData.swift
//  CognizantCurrencyDemo
//
//  Created by Curtis Stilwell on 3/24/22.
//

import Foundation

fileprivate enum ConvertDataConstants {
    static let defaultConvertValue = 0.0
}

// holds the response from the Scoop API
struct ConvertDataResponse: Codable {
    let response: ConvertData
}

// holds the response from actually converting from one currency to another
struct ConvertData: Codable, Equatable {
    let to: String
    let value: Double

    static var defaultConvertData: ConvertData {
        ConvertData(to: "", value: ConvertDataConstants.defaultConvertValue)
    }
}
