//
//  CollectionNftCellModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 25.10.2026.
//

import Foundation

struct CollectionNftCellModel: Identifiable, Equatable {
    let id: String
    let imageURL: URL?
    let name: String
    let rating: Int
    let priceText: String
    let isLiked: Bool
    let isInCart: Bool
}
