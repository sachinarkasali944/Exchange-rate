# Exchange Rate

> A SwiftUI currency converter with explicit domain logic and async networking.

A currency-conversion sample organised into networking, domain, data, and presentation layers. It uses a conversion service to keep Decimal arithmetic and validation separate from the view.

## Highlights

- Fetch exchange rates through a remote data source.
- Select currencies, convert amounts, and swap direction.
- MVVM presentation with injected dependencies.
- Included unit-test sources for conversion and presentation behaviour.

## Open and run

1. Clone this repository and open `Exchange rate/Exchange rate.xcodeproj` in Xcode.
2. Select the app scheme and a simulator compatible with the deployment target in **Build Settings → iOS Deployment Target**. Use an Xcode version with SDK support for that target.
3. Build and run with **⌘R**. For a physical device, select your development team.

```bash
git clone https://github.com/sachinarkasali944/Exchange-rate.git
cd Exchange-rate
open "Exchange rate/Exchange rate.xcodeproj"
```

## Demo scope

Rate fetching requires internet access and the external provider. Published reference rates are not a guaranteed executable market quote.

## Explore the code

- [Xcode project](./Exchange%20rate/Exchange%20rate.xcodeproj)
- [Project files](./Exchange%20rate)

## Further reading

[Read the detailed implementation guide](./Exchange%20rate/README.md).
