//
//  CatalogPreviewData.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 22.10.2026.
//

import Foundation

extension NftCollection {
    static let mocks: [NftCollection] = [
        ("1", "Peach", 11),
        ("2", "Blue", 6),
        ("3", "Brown", 8),
        ("4", "Beige", 3),
        ("5", "Green", 5),
        ("6", "Gray", 9)
    ].map { id, name, count in
        NftCollection(
            id: id,
            name: name,
            cover: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Обложки_коллекций/\(name).png"),
            nfts: (0..<count).map(String.init),
            description: "",
            author: "",
            website: nil
        )
    }
}

struct CollectionsServiceStub: CollectionsService {
    var collections = NftCollection.mocks

    func loadCollections(page: Int, size: Int) async throws -> [NftCollection] {
        Array(collections.dropFirst(page * size).prefix(size))
    }
}
