//
//  PokemonGridView.swift
//  PokeApp
//
//  Created by vivi on 28/10/25.
//

import SwiftUI

struct PokemonGridView: View {
    @StateObject private var vm: PokemonGridViewModel
    private let repo: PokemonRepositoryType
    
    init(repo: PokemonRepositoryType) {
        self.repo = repo
        _vm = StateObject(wrappedValue: PokemonGridViewModel(repo: repo))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.blue.opacity(0.15), .clear],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
                
                ScrollView {
                    GlassEffectContainer(cornerRadius: 24) {
                        LazyVGrid(
                            columns: [GridItem(.flexible(), spacing: 16),
                                      GridItem(.flexible(), spacing: 16)],
                            spacing: 16
                        ) {
                            ForEach(vm.items) { item in
                                NavigationLink(value: item.id) {
                                    PokemonCell(item: item)
                                        .padding(.horizontal, 2)
                                }
                                .buttonStyle(.plain)
                                .task {
                                    await vm.loadNextPageIfNeeded(currentItem: item)
                                }
                            }
                        }
                        .padding(6)
                    }
                    .frame(maxWidth: 720, alignment: .center)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .verticalFadeMask(edgeFraction: 0.06)
                .refreshable { await vm.refresh() }
                
                if case .error(let message) = vm.state, vm.items.isEmpty {
                    ContentUnavailableView("Couldn’t load Pokémon",
                                           systemImage: "wifi.exclamationmark",
                                           description: Text(message))
                }
            }
            .navigationTitle("Pokémon")
            .navigationDestination(for: Int.self) { id in
                PokemonDetailView(idOrName: String(id), repo: repo)
            }
        }
        .task { await vm.loadNextPageIfNeeded(currentItem: nil) }
    }
}
