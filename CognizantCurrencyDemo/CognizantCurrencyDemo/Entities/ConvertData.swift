//
//  ConvertData.swift
//  CognizantCurrencyDemo
//
//  Created by Curtis Stilwell on 3/24/22.
//

import Foundation

struct ConvertDataResponse: Codable {
    let response: ConvertData
}

struct ConvertData: Codable {
    let value: Double
}
