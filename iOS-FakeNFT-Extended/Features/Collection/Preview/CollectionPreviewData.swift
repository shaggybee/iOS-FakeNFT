//
//  CollectionPreviewData.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 25.10.2026.
//

import Foundation

extension NftCollection {
    static let peachMock = NftCollection(
        id: "1",
        name: "Peach",
        cover: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Обложки_коллекций/Peach.png"),
        nfts: CollectionNftCellModel.mocks.map(\.id),
        description: "Персиковый — как облака над закатным солнцем в океане. "
            + "В этой коллекции совмещены трогательная нежность и живая игривость сказочных зефирных зверей.",
        author: "John Doe",
        website: nil
    )
}

struct CollectionServiceStub: CollectionService {
    var collection = NftCollection.peachMock

    func loadCollection(id: String) async throws -> NftCollection {
        collection
    }
}

extension CollectionNftCellModel {
    static let mocks: [CollectionNftCellModel] = [
        ("Archie", true, true),
        ("Ruby", true, true),
        ("Nacho", true, true),
        ("Biscuit", false, false),
        ("Daisy", false, false),
        ("Susan", false, false),
        ("Oreo", false, false),
        ("Pixi", false, false),
        ("Zoe", false, false),
        ("Tater", false, false)
    ].enumerated().map { index, item in
        let (name, isLiked, isInCart) = item
        return CollectionNftCellModel(
            id: String(index),
            imageURL: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Peach/\(name)/1.png"),
            name: name,
            rating: 2,
            price: 1,
            isLiked: isLiked,
            isInCart: isInCart
        )
    }
}
