//
//  RemoteCurrencyRepository.swift
//  Exchange rate
//
//  Data/Repository/RemoteCurrencyRepository.swift
//

import Foundation


final class RemoteCurrencyRepository:
    CurrencyRepository {

    private let networkClient: NetworkClient

    private let baseURL: URL


    init(
        networkClient: NetworkClient,
        baseURL: URL
    ) {
        self.networkClient = networkClient
        self.baseURL = baseURL
    }


    func fetchExchangeRates()
        async throws -> ExchangeRates {

        var request =
            URLRequest(url: baseURL)

        request.httpMethod = "GET"

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )


        let response: ExchangeRateDTO =
            try await networkClient.request(request)


        let rates = Dictionary(
            uniqueKeysWithValues:
                response.rates.map { key, value in

                    (
                        Currency(code: key),
                        value
                    )
                }
        )


        /*
         Add base currency explicitly.

         Example API:

             USD:
                 INR = 88
                 EUR = 0.85

         We need:

             USD = 1

         for the conversion formula.
         */

        var finalRates = rates

        finalRates[
            Currency(code: response.base)
        ] = 1


        return ExchangeRates(
            baseCurrency:
                Currency(code: response.base),

            rates: finalRates
        )
    }
}
