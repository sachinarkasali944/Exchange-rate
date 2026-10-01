//
//  NetworkClient.swift
//  Exchange rate
//
//  Core/Networking/NetworkClient.swift
//

import Foundation


// ============================================================
// PROTOCOL
// ============================================================

protocol NetworkClient {

    func request<T: Decodable>(
        _ request: URLRequest
    ) async throws -> T
}


// ============================================================
// ERRORS
// ============================================================

enum NetworkError: Error {

    case invalidResponse

    case httpError(Int)

    case decodingError

    case invalidURL
}


// ============================================================
// DEFAULT IMPLEMENTATION
// ============================================================

final class URLSessionNetworkClient: NetworkClient {

    private let session: URLSession

    private let decoder: JSONDecoder


    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.decoder = decoder
    }


    func request<T: Decodable>(
        _ request: URLRequest
    ) async throws -> T {

        let (data, response) =
            try await session.data(for: request)


        guard let httpResponse =
                response as? HTTPURLResponse
        else {
            throw NetworkError.invalidResponse
        }


        guard
            200...299 ~= httpResponse.statusCode
        else {
            throw NetworkError.httpError(
                httpResponse.statusCode
            )
        }


        do {

            return try decoder.decode(
                T.self,
                from: data
            )

        } catch {

            throw NetworkError.decodingError
        }
    }
}
