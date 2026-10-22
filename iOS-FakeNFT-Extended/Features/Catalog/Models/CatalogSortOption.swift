//
//  CatalogSortOption.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 23.10.2026.
//

import Foundation

enum CatalogSortOption: CaseIterable {
    case name
    case nftCount

    var title: String {
        switch self {
        case .name:
            "По названию"
        case .nftCount:
            "По количеству NFT"
        }
    }
}
