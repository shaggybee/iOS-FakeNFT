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
        nfts: Nft.peachMocks.map(\.id),
        description: "Персиковый — как облака над закатным солнцем в океане. "
            + "В этой коллекции совмещены трогательная нежность и живая игривость сказочных зефирных зверей.",
        author: "John Doe",
        website: nil
    )
}

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

extension CollectionNftCellModel {
    static let mocks: [CollectionNftCellModel] = Nft.peachMocks.enumerated().map { index, nft in
        CollectionNftCellModel(
            id: nft.id,
            imageURL: nft.images.first,
            name: nft.name,
            rating: nft.rating,
            price: nft.price,
            isLiked: index < 3,
            isInCart: index < 3
        )
    }
}

struct CollectionServiceStub: CollectionService {
    var collection = NftCollection.peachMock

    func loadCollection(id: String) async throws -> NftCollection {
        collection
    }
}

actor LikesServiceStub: LikesService {
    static let shared = LikesServiceStub()

    private var likes: Set<String>

    init(likes: Set<String> = ["0", "1", "2"]) {
        self.likes = likes
    }

    func loadLikes() async throws -> Set<String> {
        likes
    }

    func updateLikes(_ likes: Set<String>) async throws {
        self.likes = likes
    }
}

actor CartServiceStub: CartService {
    static let shared = CartServiceStub()

    private var nfts: Set<String>

    init(nfts: Set<String> = ["0", "1", "2"]) {
        self.nfts = nfts
    }

    func loadCart() async throws -> Set<String> {
        nfts
    }

    func updateCart(_ nfts: Set<String>) async throws {
        self.nfts = nfts
    }
}

struct NftServiceStub: NftService {
    var nfts = Nft.peachMocks

    func loadNft(id: String) async throws -> Nft {
        guard let nft = nfts.first(where: { $0.id == id }) else {
            throw NetworkClientError.httpStatusCode(404)
        }
        return nft
    }
}
