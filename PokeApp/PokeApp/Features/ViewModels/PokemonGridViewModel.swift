//
//  PokemonGridViewModel.swift
//  PokeApp
//
//  Created by vivi on 28/10/25.
//

import Foundation

@MainActor
final class PokemonGridViewModel: ObservableObject {
    enum State: Equatable { case idle, loading, loadedAll, error(String) }
    
    @Published private(set) var items: [PokemonListItem] = []
    @Published private(set) var state: State = .idle
    
    private let repo: PokemonRepositoryType
    private let pageSize = 24
    private var offset = 0
    private var total = Int.max
    private var isLoading = false
    
    init(repo: PokemonRepositoryType) {
        self.repo = repo
    }
    
    func loadNextPageIfNeeded(currentItem: PokemonListItem?) async {
        guard !isLoading, items.count < total else { return }
        guard let currentItem else {
            await loadPage()
            return
        }
        if let idx = items.firstIndex(where: { $0.id == currentItem.id }) {
            let threshold = items.index(items.endIndex, offsetBy: -8, limitedBy: items.startIndex) ?? items.startIndex
            if idx >= threshold { await loadPage() }
        }
    }
    
    private func loadPage() async {
        isLoading = true
        state = .loading
        do {
            let page = try await repo.fetchPage(limit: pageSize, offset: offset)
            if total == .max { total = page.count }
            items.append(contentsOf: page.results)
            offset += page.results.count
            state = (items.count >= total) ? .loadedAll : .idle
        } catch {
            state = .error(error.localizedDescription)
        }
        isLoading = false
    }
    
    func refresh() async {
        guard !isLoading else { return }
        items.removeAll()
        offset = 0
        total = .max
        state = .idle
        await loadPage()
    }
}
