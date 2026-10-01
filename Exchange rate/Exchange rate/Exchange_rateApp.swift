//
//  Exchange_rateApp.swift
//  Exchange rate
//
//  APP COMPOSITION ROOT
//
//  This is where Dependency Injection happens.
//
//  The ViewModel doesn't create:
//
//      URLSessionNetworkClient
//      Repository
//      ConversionService
//
//  The composition root creates them.
//

import SwiftUI


@main
struct CurrencyConverterApp: App {

    private let viewModel:
        CurrencyConverterViewModel


    init() {

        let networkClient =
            URLSessionNetworkClient()


        /*
         frankfurter.app is free, no API key needed.
         Returns rates relative to EUR by default.

         In an interview, use whatever URL
         the interviewer provides here.
         */
        let apiURL =
            URL(
                string:
                    "https://api.frankfurter.app/latest"
            )!


        let repository =
            RemoteCurrencyRepository(
                networkClient: networkClient,
                baseURL: apiURL
            )


        let conversionService =
            DefaultCurrencyConversionService()


        viewModel =
            CurrencyConverterViewModel(
                repository: repository,
                conversionService:
                    conversionService
            )
    }


    var body: some Scene {

        WindowGroup {

            CurrencyConverterView(
                viewModel: viewModel
            )
        }
    }
}
