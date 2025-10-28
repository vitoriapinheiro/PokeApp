//
//  HTTPClient.swift
//  PokeApp
//
//  Created by vivi on 28/10/25.
//

import Foundation

protocol HTTPClient {
    func get<T: Decodable>(_ url: URL, as type: T.Type) async throws -> T
    func getData(_ url: URL) async throws -> Data
}

final class DefaultHTTPClient: HTTPClient {
    private let session: URLSession
    
    init(session: URLSession = DefaultHTTPClient.makeSession()) {
        self.session = session
    }
    
    static func makeSession() -> URLSession {
        let cfg = URLSessionConfiguration.default
        cfg.httpMaximumConnectionsPerHost = 4
        cfg.timeoutIntervalForRequest = 30
        cfg.requestCachePolicy = .returnCacheDataElseLoad
        cfg.urlCache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity: 200 * 1024 * 1024
        )
        return URLSession(configuration: cfg)
    }
    
    func get<T: Decodable>(_ url: URL, as type: T.Type) async throws -> T {
        let data = try await fetchWithRetry(url)
        return try JSONDecoder.pokeDecoder.decode(T.self, from: data)
    }
    
    func getData(_ url: URL) async throws -> Data {
        try await fetchWithRetry(url)
    }
    
    private func fetchWithRetry(_ url: URL, maxRetries: Int = 3) async throws -> Data {
        var attempt = 0
        var lastError: Error = URLError(.unknown)
        
        while attempt <= maxRetries {
            do {
                var req = URLRequest(url: url)
                req.addValue("PokeApp (iOS)", forHTTPHeaderField: "User-Agent")
                let (data, response) = try await session.data(for: req)
                try Self.validate(response: response)
                return data
            } catch {
                lastError = error
                attempt += 1
                if attempt > maxRetries { break }
                let delay = UInt64(pow(2.0, Double(attempt)) * 0.2 * 1_000_000_000)
                try? await Task.sleep(nanoseconds: delay)
            }
        }
        throw lastError
    }
    
    private static func validate(response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        switch http.statusCode {
            case 200..<300: return
            case 429: throw URLError(.networkConnectionLost)
            default: throw URLError(.badServerResponse)
        }
    }
}

extension JSONDecoder {
    static var pokeDecoder: JSONDecoder {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }
}
