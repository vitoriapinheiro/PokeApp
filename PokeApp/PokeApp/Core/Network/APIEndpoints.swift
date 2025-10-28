//
//  APIEndpoints.swift
//  PokeApp
//
//  Created by vivi on 28/10/25.
//

import Foundation

enum APIEndpoints {
    private static let base = URL(string: "https://pokeapi.co/api/v2")!
    
    static func pokemonList(limit: Int, offset: Int) -> URL {
        var comps = URLComponents(url: base.appendingPathComponent("pokemon"), resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            .init(name: "limit", value: String(limit)),
            .init(name: "offset", value: String(offset))
        ]
        return comps.url!
    }
    
    static func pokemonDetail(idOrName: String) -> URL {
        base.appendingPathComponent("pokemon").appendingPathComponent(idOrName)
    }
    
    static func typeDetail(_ name: String) -> URL {
        base.appendingPathComponent("type").appendingPathComponent(name)
    }
}
