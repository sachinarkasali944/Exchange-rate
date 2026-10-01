//
//  ExchangeRates.swift
//  Exchange rate
//
//  Domain/Models/ExchangeRates.swift
//

import Foundation

struct ExchangeRates {

    let baseCurrency: Currency

    /*
     Example:

     [
         "USD": 1,
         "INR": 88.0,
         "EUR": 0.85
     ]
     */

    let rates: [Currency: Decimal]
}
