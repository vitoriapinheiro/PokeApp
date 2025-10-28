//
//  CachedAsyncImage.swift
//  PokeApp
//
//  Created by vivi on 28/10/25.
//
import SwiftUI
import UIKit

struct CachedAsyncImage: View {
    let url: URL?
    var reloadTrigger: Int = 0
    var onResult: ((Bool) -> Void)? = nil
    
    @State private var uiImage: UIImage?
    @State private var isLoading = false
    @State private var error: Error?
    @State private var task: Task<Void, Never>?
    
    var body: some View {
        Group {
            if let img = uiImage {
                Image(uiImage: img).resizable()
            } else if isLoading {
                Image("Pokeball").resizable().scaledToFit().opacity(0.3)
            } else if error != nil || url == nil {
                Image("Pokeball").resizable().scaledToFit().opacity(0.6)
            } else {
                Image("Pokeball").resizable().scaledToFit().opacity(0.3)
                    .task { startLoad() }
            }
        }
        .onDisappear { task?.cancel() }
        .onChange(of: url?.absoluteString) { _ in reset() }
        .onChange(of: reloadTrigger) { _ in
            reset()
            startLoad()
        }
    }
    
    private func reset() {
        task?.cancel()
        uiImage = nil
        error = nil
        isLoading = false
    }
    
    private func startLoad() {
        guard !isLoading, uiImage == nil, let url else { return }
        isLoading = true
        task = Task { @MainActor in
            defer { isLoading = false }
            if let cached = await ImageCache.shared.image(for: url) {
                uiImage = cached
                onResult?(true)
                return
            }
            do {
                let data = try await ImageLoader.shared.data(for: url)
                if Task.isCancelled { return }
                if let img = UIImage(data: data) {
                    await ImageCache.shared.insert(img, for: url)
                    uiImage = img
                    onResult?(true)
                } else {
                    throw URLError(.cannotDecodeContentData)
                }
            } catch {
                self.error = error
                onResult?(false)
            }
        }
    }
}
