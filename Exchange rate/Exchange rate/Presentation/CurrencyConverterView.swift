//
//  CurrencyConverterView.swift
//  Exchange rate
//
//  Presentation/CurrencyConverterView.swift
//

import SwiftUI


struct CurrencyConverterView: View {

    @StateObject private var viewModel:
        CurrencyConverterViewModel


    init(
        viewModel: CurrencyConverterViewModel
    ) {
        _viewModel =
            StateObject(
                wrappedValue: viewModel
            )
    }


    var body: some View {

        NavigationStack {

            content
                .navigationTitle("Currency Converter")
                .task {
                    await viewModel.fetchRates()
                }
        }
    }


    @ViewBuilder
    private var content: some View {

        switch viewModel.state {

        case .idle,
             .loading:

            ProgressView("Loading rates...")


        case .error(let message):

            VStack(spacing: 16) {

                Text(message)
                    .multilineTextAlignment(.center)


                Button("Retry") {

                    Task {
                        await viewModel.retry()
                    }
                }
            }
            .padding()


        case .loaded:

            converterView
        }
    }


    private var converterView: some View {

        Form {

            // =================================================
            // AMOUNT
            // =================================================

            Section("Amount") {

                TextField(
                    "Enter amount",
                    text: $viewModel.amount
                )
                .keyboardType(.decimalPad)
            }


            // =================================================
            // SOURCE
            // =================================================

            Section("From") {

                Picker(
                    "From",
                    selection:
                        $viewModel.sourceCurrency
                ) {

                    ForEach(
                        viewModel.currencies
                    ) { currency in

                        Text(currency.code)
                            .tag(
                                Optional(currency)
                            )
                    }
                }
            }


            // =================================================
            // SWAP
            // =================================================

            Section {

                Button {

                    viewModel.swapCurrencies()

                } label: {

                    HStack {

                        Spacer()

                        Image(
                            systemName:
                                "arrow.up.arrow.down"
                        )

                        Text("Swap")

                        Spacer()
                    }
                }
            }


            // =================================================
            // TARGET
            // =================================================

            Section("To") {

                Picker(
                    "To",
                    selection:
                        $viewModel.targetCurrency
                ) {

                    ForEach(
                        viewModel.currencies
                    ) { currency in

                        Text(currency.code)
                            .tag(
                                Optional(currency)
                            )
                    }
                }
            }


            // =================================================
            // CONVERT
            // =================================================

            Section {

                Button("Convert") {

                    viewModel.convert()
                }
            }


            // =================================================
            // RESULT
            // =================================================

            if let result =
                viewModel.convertedAmount {

                Section("Result") {

                    Text(
                        result.formatted(
                            .number.precision(
                                .fractionLength(2)
                            )
                        )
                    )
                    .font(.title2)
                }
            }
        }
    }
}
