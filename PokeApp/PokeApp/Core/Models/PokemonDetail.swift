//
//  PokemonDetail.swift
//  PokeApp
//
//  Created by vivi on 28/10/25.
//

import Foundation

struct PokemonDetail: Decodable, Equatable {
    struct TypeSlot: Decodable, Equatable {
        let slot: Int
        let type: NamedAPIResource
    }
    struct NamedAPIResource: Decodable, Equatable {
        let name: String
        let url: String
    }
    struct Stat: Decodable, Equatable {
        let baseStat: Int
        let effort: Int
        let stat: NamedAPIResource
    }
    struct AbilitySlot: Decodable, Equatable {
        let isHidden: Bool
        let slot: Int
        let ability: NamedAPIResource
    }
    
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let types: [TypeSlot]
    let stats: [Stat]
    let abilities: [AbilitySlot]
}
