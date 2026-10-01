//
//  ExchangeRateDTO.swift
//  Exchange rate
//
//  Data/DTO/ExchangeRateDTO.swift
//

import Foundation

/*
 Assume API response:

 {
     "base": "USD",
     "rates": {
         "INR": 88.0,
         "EUR": 0.85,
         "GBP": 0.74
     }
 }
 */

struct ExchangeRateDTO: Decodable {

    let base: String

    let rates: [String: Decimal]
}
