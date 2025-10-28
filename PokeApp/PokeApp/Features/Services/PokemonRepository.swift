//
//  PokemonRepository.swift
//  PokeApp
//
//  Created by vivi on 28/10/25.
//

import Foundation

// MARK: - Protocol
protocol PokemonRepositoryType {
    func fetchPage(limit: Int, offset: Int) async throws -> PokemonListResponse
    func fetchDetail(idOrName: String) async throws -> PokemonDetail
    func fetchTypeDetail(_ name: String) async throws -> TypeDetail
}

// MARK: - Implementation
final class PokemonRepository: PokemonRepositoryType {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func fetchPage(limit: Int, offset: Int) async throws -> PokemonListResponse {
        try await client.get(APIEndpoints.pokemonList(limit: limit, offset: offset),
                             as: PokemonListResponse.self)
    }
    
    func fetchDetail(idOrName: String) async throws -> PokemonDetail {
        try await client.get(APIEndpoints.pokemonDetail(idOrName: idOrName),
                             as: PokemonDetail.self)
    }
    
    func fetchTypeDetail(_ name: String) async throws -> TypeDetail {
        try await client.get(APIEndpoints.typeDetail(name),
                             as: TypeDetail.self)
    }
}

// MARK: - TypeDetail model
struct TypeDetail: Decodable, Equatable {
    struct DamageRelations: Decodable, Equatable {
        let doubleDamageFrom: [PokemonDetail.NamedAPIResource]
        let doubleDamageTo: [PokemonDetail.NamedAPIResource]
        let halfDamageFrom: [PokemonDetail.NamedAPIResource]
        let halfDamageTo: [PokemonDetail.NamedAPIResource]
    }
    
    let name: String
    let damageRelations: DamageRelations
}
