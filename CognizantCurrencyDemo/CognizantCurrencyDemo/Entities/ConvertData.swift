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

struct ConvertDataResponse: Codable {
    let response: ConvertData
}

struct ConvertData: Codable, Equatable {
    let to: String
    let value: Double

    static var defaultConvertData: ConvertData {
        ConvertData(to: "", value: ConvertDataConstants.defaultConvertValue)
    }
}
