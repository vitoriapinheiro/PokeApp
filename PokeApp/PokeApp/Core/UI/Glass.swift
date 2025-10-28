//
//  Glass.swift
//  PokeApp
//
//  Created by vivi on 28/10/25.
//

import SwiftUI

struct GlassEffectContainer<Content: View>: View {
    let cornerRadius: CGFloat
    @ViewBuilder var content: Content
    
    init(cornerRadius: CGFloat = 32, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(.ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}

private struct GlassEffect: ViewModifier {
    var tint: Color = .white
    
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().stroke(tint.opacity(0.35), lineWidth: 1))
            .background(Capsule().fill(tint.opacity(0.08)))
    }
}
extension View {
    func glassEffect(tint: Color = .white) -> some View {
        modifier(GlassEffect(tint: tint))
    }
}

extension View {
    func horizontalFadeMask(edgeFraction: CGFloat = 0.05) -> some View {
        mask(
            LinearGradient(stops: [
                .init(color: .clear, location: 0.0),
                .init(color: .black,  location: edgeFraction),
                .init(color: .black,  location: 1.0 - edgeFraction),
                .init(color: .clear, location: 1.0)
            ], startPoint: .leading, endPoint: .trailing)
        )
    }
}

private struct GlassShapeEffect<S: Shape>: ViewModifier {
    let shape: S
    let tint: Color
    
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: shape)
            .overlay(shape.stroke(tint.opacity(0.35), lineWidth: 1))
            .background(shape.fill(tint.opacity(0.08)))
    }
}

extension View {
    func glassEffect<S: Shape>(shape: S, tint: Color) -> some View {
        modifier(GlassShapeEffect(shape: shape, tint: tint))
    }
}

extension View {
    func verticalFadeMask(edgeFraction: CGFloat = 0.06) -> some View {
        mask(
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0.0),
                    .init(color: .black, location: edgeFraction),
                    .init(color: .black, location: 1.0 - edgeFraction),
                    .init(color: .clear, location: 1.0)
                ],
                startPoint: .top, endPoint: .bottom
            )
        )
    }
}
