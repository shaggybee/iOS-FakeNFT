//
//  CollectionNftCellModel+Mock.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 28.10.2026.
//

import Foundation

// MARK: - Mocks

extension CollectionNftCellModel {
    static let mocks: [CollectionNftCellModel] = Nft.peachMocks.enumerated().map { index, nft in
        CollectionNftCellModel(
            id: nft.id,
            imageURL: nft.images.first,
            name: nft.name,
            rating: nft.rating,
            priceText: "\(nft.price.formatted()) ETH",
            isLiked: index < 3,
            isInCart: index < 3
        )
    }
}
