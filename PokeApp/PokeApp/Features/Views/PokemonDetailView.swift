//
//  PokemonDetailView.swift
//  PokeApp
//
//  Created by vivi on 28/10/25.
//

import SwiftUI

struct PokemonDetailView: View {
    @StateObject private var vm: PokemonDetailViewModel
    
    init(idOrName: String, repo: PokemonRepositoryType) {
        _vm = StateObject(wrappedValue: PokemonDetailViewModel(repo: repo, idOrName: idOrName))
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.accentColor.opacity(0.25), .clear],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            ScrollView {
                GlassEffectContainer {
                    VStack(spacing: 20) {
                        if let id = vm.detail?.id {
                            HeroFlipImage(id: id)
                                .frame(height: 220)
                        } else {
                            Image("Pokeball")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 220)
                                .opacity(0.3)
                        }
                        
                        
                        if let name = vm.detail?.name {
                            Text(name.capitalized)
                                .font(.largeTitle.bold())
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        
                        HStack(spacing: 16) {
                            LabeledCapsule(icon: "ruler", title: "Height", value: vm.displayHeight)
                            LabeledCapsule(icon: "scalemass", title: "Weight", value: vm.displayWeight)
                        }
                        
                        if !vm.typeNames.isEmpty {
                            BubbleSection(title: "Types", chips: vm.typeNames, tint: .blue)
                        }
                        
                        if !vm.weaknesses.isEmpty {
                            BubbleSection(title: "Weaknesses", chips: vm.weaknesses, tint: .red)
                        }
                        
                        if !vm.abilityChips.isEmpty {
                            BubbleSection(title: "Abilities", chips: vm.abilityChips, tint: .green)
                        }
                        if !vm.statChips.isEmpty {
                            BubbleSection(title: "Stats", chips: vm.statChips, tint: .yellow)
                        }
                        
                        Spacer(minLength: 12)
                    }
                    .frame(maxWidth: 640, alignment: .center)
                }.frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                
            }
            .overlay(alignment: .center) {
                if vm.detail == nil && vm.errorMessage == nil {
                    ProgressView().task { await vm.load() }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        
    }
}

private struct HeroFlipImage: View {
    let id: Int
    
    private var frontURL: URL { URL(string:
                                        "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png")!
    }
    private var backURL: URL { URL(string:
                                    "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/\(id).png")!
    }
    
    private let bubbleDiameter: CGFloat = 220
    private var imageSize: CGFloat { bubbleDiameter * 0.82 }
    private var tint: Color { TintPalette.color(for: id) }
    
    @State private var showBack = false
    @State private var frontLoaded = false
    @State private var backLoaded = false
    @State private var frontFailed = false
    @State private var backFailed = false
    @State private var retryTick = 0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.clear)
                .frame(width: bubbleDiameter, height: bubbleDiameter)
                .glassEffect(shape: Circle(), tint: tint)
            
            CachedAsyncImage(
                url: frontURL,
                reloadTrigger: retryTick,
                onResult: { ok in
                    if ok { frontLoaded = true; frontFailed = false }
                    else  { frontFailed = true }
                }
            )
            .scaledToFit()
            .frame(width: imageSize, height: imageSize)
            .mask(Circle())
            .opacity(frontOpacity)
            .animation(.easeInOut(duration: 0.2), value: frontOpacity)
            .accessibilityHidden(true)
            
            CachedAsyncImage(
                url: backURL,
                reloadTrigger: retryTick,
                onResult: { ok in
                    if ok { backLoaded = true; backFailed = false }
                    else  { backFailed = true }
                }
            )
            .scaledToFit()
            .frame(width: imageSize, height: imageSize)
            .mask(Circle())
            .opacity(backOpacity)
            .animation(.easeInOut(duration: 0.2), value: backOpacity)
            .accessibilityHidden(true)
            
            if bothFailed {
                Image("Pokeball")
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageSize * 0.85, height: imageSize * 0.85)
                    .opacity(0.6)
                    .mask(Circle())
                    .task {
                        try? await Task.sleep(nanoseconds: 60_000_000_000)
                        if bothFailed { retryTick += 1 }
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .contentShape(Rectangle())
        .onTapGesture {
            if showBack {
                if frontLoaded || !frontFailed { withAnimation(.spring()) { showBack = false } }
            } else {
                if backLoaded  || !backFailed  { withAnimation(.spring()) { showBack = true } }
            }
        }
        .accessibilityLabel(showBack ? "Back image" : "Front image")
        .accessibilityHint("Double tap to flip")
    }
    
    private var bothFailed: Bool { frontFailed && backFailed }
    
    private var frontOpacity: CGFloat {
        if bothFailed { return 0 }
        if showBack {
            return backLoaded ? 0 : 1
        } else {
            return 1
        }
    }
    
    private var backOpacity: CGFloat {
        if bothFailed { return 0 }
        if showBack {
            return 1
        } else {
            return frontLoaded ? 0 : (backLoaded ? 1 : 0)
        }
    }
}
private struct LabeledCapsule: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
            Text(title)
                .font(.headline)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
            Text(value)
                .font(.headline.weight(.semibold))
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 14)
        .background(.thinMaterial, in: Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) \(value)")
    }
}

private struct BubbleSection: View {
    let title: String
    let chips: [String]
    let tint: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title3.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(chips, id: \.self) { chip in
                        Text(chip)
                            .font(.subheadline.weight(.semibold))
                            .lineLimit(1)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .glassEffect(tint: tint)             
                            .accessibilityLabel("\(title) \(chip)")
                    }
                }
                .padding(.horizontal, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .horizontalFadeMask()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ChipGrid: View {
    let chips: [String]
    let tint: Color
    
    private var cols: [GridItem] { [GridItem(.adaptive(minimum: 110), spacing: 8)] }
    
    var body: some View {
        LazyVGrid(columns: cols, alignment: .leading, spacing: 8) {
            ForEach(chips, id: \.self) { chip in
                Text(chip)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(Capsule().stroke(tint.opacity(0.35), lineWidth: 1))
                    .background(Capsule().fill(tint.opacity(0.08)))
                    .accessibilityLabel(chip)
            }
        }
    }
}
