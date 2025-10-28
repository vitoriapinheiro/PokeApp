//
//  ImageCache.swift
//  PokeApp
//
//  Created by vivi on 28/10/25.
//

import UIKit

actor ImageCache {
    static let shared = ImageCache()
    private let memory = NSCache<NSURL, UIImage>()
    
    func image(for url: URL) -> UIImage? {
        memory.object(forKey: url as NSURL)
    }
    
    func insert(_ image: UIImage, for url: URL) {
        memory.setObject(image, forKey: url as NSURL)
    }
}
