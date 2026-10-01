//
//  CurrencyRepository.swift
//  Exchange rate
//
//  Domain/Repository/CurrencyRepository.swift
//

import Foundation


protocol CurrencyRepository {

    func fetchExchangeRates() async throws
        -> ExchangeRates
}
