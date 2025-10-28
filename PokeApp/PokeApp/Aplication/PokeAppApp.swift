//
//  PokeAppApp.swift
//  PokeApp
//
//  Created by vivi on 28/10/25.
//

import SwiftUI

@main
struct PokeAppApp: App {
    @StateObject private var appContainer = CompositionRoot.makeContainer()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appContainer.dependencies)
                .preferredColorScheme(.light)
        }
    }
}
