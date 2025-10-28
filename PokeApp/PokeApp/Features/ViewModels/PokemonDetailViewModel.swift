//
//  PokemonDetailViewModel.swift
//  PokeApp
//
//  Created by vivi on 28/10/25.
//

import Foundation

@MainActor
final class PokemonDetailViewModel: ObservableObject {
    @Published private(set) var detail: PokemonDetail?
    @Published private(set) var weaknesses: [String] = []
    @Published private(set) var errorMessage: String?
    
    var displayHeight: String {
        guard let h = detail?.height else { return "—" }
        let meters = Double(h) / 10.0
        return String(format: "%.1f m", meters)
    }
    
    var displayWeight: String {
        guard let w = detail?.weight else { return "—" }
        let kg = Double(w) / 10.0
        return String(format: "%.1f kg", kg)
    }
    
    var typeNames: [String] {
        detail?.types.map { $0.type.name.capitalized } ?? []
    }
    
    var statChips: [String] {
        guard let stats = detail?.stats else { return [] }
        return stats.map { "\($0.stat.name.capitalized): \($0.baseStat)" }
    }
    
    var abilityChips: [String] {
        guard let abilities = detail?.abilities else { return [] }
        return abilities.map {"\($0.ability.name.capitalized)"
        }
    }
    
    private let repo: PokemonRepositoryType
    private let idOrName: String
    
    init(repo: PokemonRepositoryType, idOrName: String) {
        self.repo = repo
        self.idOrName = idOrName
    }
    
    func load() async {
        do {
            let d = try await repo.fetchDetail(idOrName: idOrName)
            self.detail = d
            
            let types = d.types.map { $0.type.name }
            if !types.isEmpty {
                let typeDetails = try await withThrowingTaskGroup(of: TypeDetail.self) { group in
                    for t in types { group.addTask { try await self.repo.fetchTypeDetail(t) } }
                    var collected: [TypeDetail] = []
                    for try await td in group { collected.append(td) }
                    return collected
                }
                let weakSet = Set(
                    typeDetails.flatMap { $0.damageRelations.doubleDamageFrom.map { $0.name.capitalized } }
                )
                self.weaknesses = Array(weakSet).sorted()
            } else {
                self.weaknesses = []
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
