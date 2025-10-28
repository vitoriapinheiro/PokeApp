//
//  PokemonModels.swift
//  PokeApp
//
//  Created by vivi on 28/10/25.
//

import Foundation

struct PokemonListResponse: Decodable, Equatable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokemonListItem]
}

struct PokemonListItem: Decodable, Equatable, Identifiable {
    let name: String
    let url: String
    
    var id: Int {
        if let urlObj = URL(string: url) {
            let parts = urlObj.path.split(separator: "/").filter { !$0.isEmpty }
            if let last = parts.last, let val = Int(last) {
                return val
            }
        }
        let tokens = url.split(separator: "/").filter { !$0.isEmpty }
        if let last = tokens.last, let val = Int(last) {
            return val
        }
        return 0
    }
    
    var spriteURL: URL {
        URL(string: "https://img.pokemondb.net/sprites/scarlet-violet/icon/\(name.lowercased()).png")!
    }
}
