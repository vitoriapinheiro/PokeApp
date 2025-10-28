//
//  TintPalette.swift
//  PokeApp
//
//  Created by vivi on 28/10/25.
//

import SwiftUI

enum TintPalette {
    static let colors: [Color] = [
        .yellow, .green, .orange, .pink, .blue, .red
    ]
    
    static func color(for id: Int) -> Color {
        let idx = abs(id) % colors.count
        return colors[idx]
    }
}
