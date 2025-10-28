//
//  ImageLoader.swift
//  PokeApp
//
//  Created by vivi on 28/10/25.
//

import Foundation

final class ImageLoader {
    static let shared = ImageLoader()
    
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.httpMaximumConnectionsPerHost = 4
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity: 200 * 1024 * 1024
        )
        self.session = URLSession(configuration: config)
    }
    
    func data(for url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return data
    }
}
