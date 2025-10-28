//
//  CompositionRoot.swift
//  PokeApp
//
//  Created by vivi on 28/10/25.
//

import Foundation

final class AppDependencies: ObservableObject {
    let httpClient: HTTPClient
    let pokemonRepository: PokemonRepositoryType
    
    init(httpClient: HTTPClient, pokemonRepository: PokemonRepositoryType) {
        self.httpClient = httpClient
        self.pokemonRepository = pokemonRepository
    }
}

enum CompositionRoot {
    static func makeContainer() -> AppContainer {
        let http = DefaultHTTPClient()
        let repo = PokemonRepository(client: http)
        let deps = AppDependencies(httpClient: http, pokemonRepository: repo)
        return AppContainer(dependencies: deps)
    }
}

final class AppContainer: ObservableObject {
    let dependencies: AppDependencies
    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }
}
