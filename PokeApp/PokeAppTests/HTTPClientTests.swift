//
//  HTTPClientTests.swift
//  PokeApp
//
//  Created by vivi on 28/10/25.
//

import XCTest
@testable import PokeApp

final class HTTPClientTests: XCTestCase {
    func testDecodeList() async throws {
        let json = """
        {"count": 100,"next": null,"previous": null,
         "results":[{"name":"bulbasaur","url":"https://pokeapi.co/api/v2/pokemon/1/"}]}
        """
        let (session, token) = makeSessionReturning(status: 200, body: json.data(using: .utf8)!)
        let client = DefaultHTTPClient(session: session)
        
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=1&offset=0")!
        let list: PokemonListResponse = try await client.get(url, as: PokemonListResponse.self)
        XCTAssertEqual(list.results.first?.id, 1)
        
        _ = token
    }
}


private final class MockProtocol: URLProtocol {
    static var responder: ((URLRequest) -> (Int, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        guard let responder = Self.responder else { return }
        let (status, data) = responder(request)
        let resp = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: resp, cacheStoragePolicy: .allowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() { }
}

private func makeSessionReturning(status: Int, body: Data) -> (URLSession, NSObject) {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockProtocol.self]
    MockProtocol.responder = { _ in (status, body) }
    return (URLSession(configuration: config), NSObject())
}
