# 💱 Exchange Rate App (iOS / SwiftUI)

A modern, clean, and robust iOS Currency Converter app built using **SwiftUI**, **Combine**, and **Swift Concurrency (`async/await`)**. Designed following **Clean Architecture** and **MVVM** principles.

---

## ✨ Features

- 🔄 **Real-Time Exchange Rates**: Fetches live exchange rates from the free [Frankfurter API](https://api.frankfurter.app/latest).
- 💱 **Currency Conversion**: Instant conversion between any supported currencies using exact `Decimal` arithmetic to avoid floating-point rounding errors.
- 🔁 **Currency Swap**: One-tap swapping of source and target currencies.
- ⚡ **Clean UI/UX**: Built with native SwiftUI forms, pickers, loading indicators, and retry error handling.
- 🧪 **Fully Unit Tested**: Comprehensive test suite covering domain logic, conversion service formulas, edge cases (zero/negative amounts, missing rates), and ViewModel state transitions.

---

## 🏗️ Architecture

The codebase follows **Clean Architecture** with strict separation of concerns and dependency inversion:

```
Exchange rate/
├── Core/
│   └── Networking/
│       └── NetworkClient.swift       # Generic async/await URLSession HTTP client
├── Domain/
│   ├── Models/
│   │   ├── Currency.swift            # Value type representing a currency
│   │   └── ExchangeRates.swift       # Model holding exchange rates dictionary
│   ├── Repository/
│   │   └── CurrencyRepository.swift  # Repository protocol contract
│   └── Services/
│       └── CurrencyConversionService.swift # Math & domain validation logic
├── Data/
│   ├── DTO/
│   │   └── ExchangeRateResponse.swift  # Decodable DTO for network response
│   └── Remote/
│       └── CurrencyRemoteDataSource.swift # Remote repository implementation
└── Presentation/
    ├── CurrencyConverterView.swift   # SwiftUI user interface
    └── CurrencyConverterViewModel.swift # MainActor ViewModel managing UI state
```

### Dependency Injection (App Composition Root)
All dependencies (`NetworkClient`, `CurrencyRepository`, `CurrencyConversionService`) are constructed in `Exchange_rateApp.swift` (the composition root) and injected into `CurrencyConverterViewModel`.

---

## 🧪 Testing

The unit test suite (`Exchange_rateTests.swift`) runs without network dependencies by using `MockCurrencyRepository` stubs.

### Running Tests
In Xcode, press `Cmd + U` or run via command line:
```bash
xcodebuild test -project "Exchange rate.xcodeproj" -scheme "Exchange rate" -destination "platform=iOS Simulator,name=iPhone 16"
```

---

## 🚀 Requirements & Setup

- **Xcode 16+**
- **iOS 17.0+**
- **Swift 5.9+**

### How to Run:
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/Exchange-rate.git
   ```
2. Open `Exchange rate.xcodeproj` in Xcode.
3. Select an iOS Simulator (e.g., iPhone 16) and press `Cmd + R` to run.

---

## 📄 License
MIT License. Free to use for practice and interview reference.
