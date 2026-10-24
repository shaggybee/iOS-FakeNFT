//
//  NftSortOption.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 23.10.2026.
//

enum NftSortOption: String, CaseIterable {
    case price
    case rating
    case title

    var title: String {
        switch self {
        case .title:
            "По названию"
        case .rating:
            "По рейтингу"
        case .price:
            "По цене"
        }
    }
}
