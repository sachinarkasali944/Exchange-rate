//
//  Exchange_rateTests.swift
//  Exchange rateTests
//

import XCTest
@testable import Exchange_rate


// ============================================================
// CurrencyConversionService Tests
// ============================================================

final class CurrencyConversionServiceTests: XCTestCase {

    var sut: DefaultCurrencyConversionService!
    var rates: ExchangeRates!


    override func setUp() {
        super.setUp()

        sut = DefaultCurrencyConversionService()

        /*
         Fixture: USD-based rates

         USD = 1
         EUR = 0.85
         INR = 88.0
         */
        rates = ExchangeRates(
            baseCurrency: Currency(code: "USD"),
            rates: [
                Currency(code: "USD"): Decimal(1),
                Currency(code: "EUR"): Decimal(string: "0.85")!,
                Currency(code: "INR"): Decimal(string: "88.0")!
            ]
        )
    }


    override func tearDown() {
        sut = nil
        rates = nil
        super.tearDown()
    }


    // ========================================================
    // HAPPY PATH
    // ========================================================

    // 100 USD → INR = 100 × 88 / 1 = 8800
    func test_convert_usdToInr_returnsCorrectValue() throws {

        let result = try sut.convert(
            amount: 100,
            from: Currency(code: "USD"),
            to: Currency(code: "INR"),
            rates: rates
        )

        XCTAssertEqual(
            result,
            Decimal(8800),
            "100 USD should equal 8800 INR"
        )
    }


    // 100 EUR → INR = 100 × 88 / 0.85 ≈ 10352.94
    func test_convert_eurToInr_crossCurrencyFormula() throws {

        let result = try sut.convert(
            amount: 100,
            from: Currency(code: "EUR"),
            to: Currency(code: "INR"),
            rates: rates
        )

        // amount × targetRate / sourceRate
        let expected =
            Decimal(100)
            * Decimal(string: "88.0")!
            / Decimal(string: "0.85")!

        XCTAssertEqual(
            result,
            expected,
            "Cross-currency EUR→INR must use amount × targetRate / sourceRate"
        )
    }


    // Same currency should return the same amount
    func test_convert_sameCurrency_returnsIdenticalAmount() throws {

        let result = try sut.convert(
            amount: 250,
            from: Currency(code: "USD"),
            to: Currency(code: "USD"),
            rates: rates
        )

        XCTAssertEqual(result, 250)
    }


    // Zero amount should return zero, not throw
    func test_convert_zeroAmount_returnsZero() throws {

        let result = try sut.convert(
            amount: .zero,
            from: Currency(code: "USD"),
            to: Currency(code: "INR"),
            rates: rates
        )

        XCTAssertEqual(result, .zero)
    }


    // ========================================================
    // ERROR CASES
    // ========================================================

    // Negative amount → .invalidAmount
    func test_convert_negativeAmount_throwsInvalidAmount() {

        XCTAssertThrowsError(
            try sut.convert(
                amount: -1,
                from: Currency(code: "USD"),
                to: Currency(code: "INR"),
                rates: rates
            )
        ) { error in
            XCTAssertEqual(
                error as? ConversionError,
                .invalidAmount
            )
        }
    }


    // Unknown source currency → .currencyNotFound
    func test_convert_unknownSourceCurrency_throwsCurrencyNotFound() {

        XCTAssertThrowsError(
            try sut.convert(
                amount: 100,
                from: Currency(code: "XYZ"),
                to: Currency(code: "INR"),
                rates: rates
            )
        ) { error in
            XCTAssertEqual(
                error as? ConversionError,
                .currencyNotFound
            )
        }
    }


    // Unknown target currency → .currencyNotFound
    func test_convert_unknownTargetCurrency_throwsCurrencyNotFound() {

        XCTAssertThrowsError(
            try sut.convert(
                amount: 100,
                from: Currency(code: "USD"),
                to: Currency(code: "FAKE"),
                rates: rates
            )
        ) { error in
            XCTAssertEqual(
                error as? ConversionError,
                .currencyNotFound
            )
        }
    }


    // Zero source rate → .invalidRate
    func test_convert_zeroSourceRate_throwsInvalidRate() {

        let badRates = ExchangeRates(
            baseCurrency: Currency(code: "USD"),
            rates: [
                Currency(code: "USD"): .zero,   // corrupt
                Currency(code: "INR"): Decimal(string: "88")!
            ]
        )

        XCTAssertThrowsError(
            try sut.convert(
                amount: 100,
                from: Currency(code: "USD"),
                to: Currency(code: "INR"),
                rates: badRates
            )
        ) { error in
            XCTAssertEqual(
                error as? ConversionError,
                .invalidRate
            )
        }
    }
}


// ============================================================
// ViewModel Tests
// ============================================================

@MainActor
final class CurrencyConverterViewModelTests: XCTestCase {

    var mockRepository: MockCurrencyRepository!
    var sut: CurrencyConverterViewModel!


    override func setUp() {
        super.setUp()

        mockRepository = MockCurrencyRepository()

        sut = CurrencyConverterViewModel(
            repository: mockRepository,
            conversionService:
                DefaultCurrencyConversionService()
        )
    }


    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }


    // ========================================================
    // FETCH RATES
    // ========================================================

    func test_fetchRates_success_setsLoadedState() async {

        mockRepository.stubbedRates = makeRates()

        await sut.fetchRates()

        if case .loaded = sut.state {
            // ✅
        } else {
            XCTFail("Expected .loaded, got \(sut.state)")
        }

        XCTAssertFalse(sut.currencies.isEmpty)
    }


    func test_fetchRates_failure_setsErrorState() async {

        mockRepository.stubbedError =
            NetworkError.httpError(500)

        await sut.fetchRates()

        if case .error = sut.state {
            // ✅
        } else {
            XCTFail("Expected .error, got \(sut.state)")
        }
    }


    // ========================================================
    // CONVERT
    // ========================================================

    func test_convert_validInput_setsConvertedAmount() async {

        mockRepository.stubbedRates = makeRates()
        await sut.fetchRates()

        sut.sourceCurrency = Currency(code: "USD")
        sut.targetCurrency = Currency(code: "INR")
        sut.amount = "100"
        sut.convert()

        XCTAssertEqual(
            sut.convertedAmount,
            Decimal(8800),
            "100 USD → INR should be 8800"
        )
    }


    func test_convert_withoutRates_doesNotSetConvertedAmount() {

        // rates not fetched
        sut.amount = "100"
        sut.convert()

        XCTAssertNil(sut.convertedAmount)
    }


    // ========================================================
    // SWAP
    // ========================================================

    func test_swapCurrencies_swapsSourceAndTarget() async {

        mockRepository.stubbedRates = makeRates()
        await sut.fetchRates()

        sut.sourceCurrency = Currency(code: "USD")
        sut.targetCurrency = Currency(code: "INR")

        sut.swapCurrencies()

        XCTAssertEqual(sut.sourceCurrency?.code, "INR")
        XCTAssertEqual(sut.targetCurrency?.code, "USD")
    }


    // ========================================================
    // HELPER
    // ========================================================

    private func makeRates() -> ExchangeRates {
        ExchangeRates(
            baseCurrency: Currency(code: "USD"),
            rates: [
                Currency(code: "USD"): Decimal(1),
                Currency(code: "EUR"): Decimal(string: "0.85")!,
                Currency(code: "INR"): Decimal(string: "88.0")!
            ]
        )
    }
}


// ============================================================
// MockCurrencyRepository
//
// In-process test double.
// No networking. No URLSession.
// Just a configurable stub.
// ============================================================

final class MockCurrencyRepository: CurrencyRepository {

    var stubbedRates: ExchangeRates?
    var stubbedError: Error?


    func fetchExchangeRates() async throws -> ExchangeRates {

        if let error = stubbedError {
            throw error
        }

        guard let rates = stubbedRates else {
            throw NetworkError.invalidResponse
        }

        return rates
    }
}
