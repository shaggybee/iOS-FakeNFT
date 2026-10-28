//
//  Nft+Mock.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 28.10.2026.
//

import Foundation

// MARK: - Mocks

extension Nft {
    static let peachMocks: [Nft] = [
        "Archie", "Ruby", "Nacho", "Biscuit", "Daisy",
        "Susan", "Oreo", "Pixi", "Zoe", "Tater"
    ].enumerated().map { index, name in
        Nft(
            id: String(index),
            name: name,
            images: [URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Peach/\(name)/1.png")].compactMap { $0 },
            rating: 2,
            price: 1
        )
    }
}
