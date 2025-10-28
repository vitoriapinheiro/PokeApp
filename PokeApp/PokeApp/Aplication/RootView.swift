//
//  RootView.swift
//  PokeApp
//
//  Created by vivi on 28/10/25.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var deps: AppDependencies
    
    var body: some View {
        PokemonGridView(repo: deps.pokemonRepository)
    }
}
