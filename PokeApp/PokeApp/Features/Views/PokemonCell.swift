//
//  PokemonCell.swift
//  PokeApp
//
//  Created by vivi on 28/10/25.
//
import SwiftUI

struct PokemonCell: View {
    let item: PokemonListItem
    private var tint: Color { TintPalette.color(for: item.id) }
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 116, height: 116)
                    .glassEffect(shape: Circle(), tint: tint)
                
                CachedAsyncImage(url: item.spriteURL)
                    .scaledToFit()
                    .frame(width: 96, height: 96)
                    .accessibilityHidden(true)
            }
            .frame(width: 116, height: 116)
            
            Text(item.name.capitalized)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(item.name)
    }
}
