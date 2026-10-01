//
//  CurrencyConversionService.swift
//  Exchange rate
//
//  Domain/Services/CurrencyConversionService.swift
//

import Foundation


// ============================================================
// PROTOCOL
// ============================================================

protocol CurrencyConversionService {

    func convert(
        amount: Decimal,
        from source: Currency,
        to target: Currency,
        rates: ExchangeRates
    ) throws -> Decimal
}


// ============================================================
// ERRORS
// ============================================================

enum ConversionError: LocalizedError {

    case invalidAmount

    case currencyNotFound

    case invalidRate


    var errorDescription: String? {

        switch self {

        case .invalidAmount:
            return "Amount must be greater than or equal to 0."

        case .currencyNotFound:
            return "Exchange rate not available."

        case .invalidRate:
            return "Invalid exchange rate."
        }
    }
}


// ============================================================
// IMPLEMENTATION
// ============================================================

final class DefaultCurrencyConversionService:
    CurrencyConversionService {


    func convert(
        amount: Decimal,
        from source: Currency,
        to target: Currency,
        rates: ExchangeRates
    ) throws -> Decimal {


        guard amount >= 0 else {
            throw ConversionError.invalidAmount
        }


        guard
            let sourceRate = rates.rates[source],
            let targetRate = rates.rates[target]
        else {
            throw ConversionError.currencyNotFound
        }


        guard sourceRate > 0 else {
            throw ConversionError.invalidRate
        }


        /*
         Example:

         API base = USD

         USD = 1
         EUR = 0.85
         INR = 88


         100 EUR -> INR

         Formula:

             amount × targetRate / sourceRate

             100 × 88 / 0.85

             = 10352.94 INR
         */

        return amount
            * targetRate
            / sourceRate
    }
}
