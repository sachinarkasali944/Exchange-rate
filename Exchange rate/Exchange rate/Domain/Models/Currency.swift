//
//  Currency.swift
//  Exchange rate
//
//  Domain/Models/Currency.swift
//

struct Currency: Hashable, Identifiable {

    let code: String

    var id: String {
        code
    }
}
