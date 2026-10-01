//
//  CurrencyConverterViewModel.swift
//  Exchange rate
//
//  Presentation/CurrencyConverterViewModel.swift
//

import Combine
import Foundation


@MainActor
final class CurrencyConverterViewModel:
    ObservableObject {


    // ========================================================
    // UI STATE
    // ========================================================

    enum State {

        case idle

        case loading

        case loaded

        case error(String)
    }


    @Published private(set) var state:
        State = .idle


    // ========================================================
    // DATA
    // ========================================================

    @Published private(set) var currencies:
        [Currency] = []


    @Published var sourceCurrency:
        Currency?


    @Published var targetCurrency:
        Currency?


    @Published var amount:
        String = ""


    @Published private(set) var convertedAmount:
        Decimal?


    // ========================================================
    // DEPENDENCIES
    // ========================================================

    private let repository:
        CurrencyRepository


    private let conversionService:
        CurrencyConversionService


    private var exchangeRates:
        ExchangeRates?


    // ========================================================
    // INIT
    // ========================================================

    init(
        repository: CurrencyRepository,
        conversionService: CurrencyConversionService
    ) {

        self.repository = repository

        self.conversionService =
            conversionService
    }


    // ========================================================
    // FETCH RATES
    // ========================================================

    func fetchRates() async {

        state = .loading


        do {

            let rates =
                try await repository.fetchExchangeRates()


            exchangeRates = rates


            currencies =
                rates.rates.keys.sorted {
                    $0.code < $1.code
                }


            /*
             Set sensible defaults.

             If API contains USD + INR + EUR,
             default to:

                 USD -> INR
             */

            if sourceCurrency == nil {

                sourceCurrency =
                    currencies.first {
                        $0.code == "USD"
                    }
                    ?? currencies.first
            }


            if targetCurrency == nil {

                targetCurrency =
                    currencies.first {
                        $0.code == "INR"
                    }
                    ?? currencies.dropFirst().first
            }


            state = .loaded


        } catch {

            state = .error(
                error.localizedDescription
            )
        }
    }


    // ========================================================
    // CONVERT
    // ========================================================

    func convert() {

        guard
            let exchangeRates,
            let sourceCurrency,
            let targetCurrency
        else {
            return
        }


        guard
            let decimalAmount =
                Decimal(string: amount)
        else {
            convertedAmount = nil
            return
        }


        do {

            convertedAmount =
                try conversionService.convert(
                    amount: decimalAmount,
                    from: sourceCurrency,
                    to: targetCurrency,
                    rates: exchangeRates
                )

        } catch {

            convertedAmount = nil
        }
    }


    // ========================================================
    // SWAP
    // ========================================================

    func swapCurrencies() {

        let currentSource =
            sourceCurrency

        sourceCurrency =
            targetCurrency

        targetCurrency =
            currentSource


        convert()
    }


    // ========================================================
    // RETRY
    // ========================================================

    func retry() async {

        await fetchRates()
    }
}
