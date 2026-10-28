//
//  NftCollection+Mock.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 28.10.2026.
//

import Foundation

// MARK: - Mocks

extension NftCollection {
    static let peachMock = NftCollection(
        id: "1",
        name: "Peach",
        cover: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Обложки_коллекций/Peach.png"),
        nfts: Nft.peachMocks.map(\.id),
        description: "Персиковый — как облака над закатным солнцем в океане. "
        + "В этой коллекции совмещены трогательная нежность и живая игривость сказочных зефирных зверей.",
        author: "John Doe",
        website: nil
    )
}
