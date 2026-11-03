//
//  CatalogSortOption.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 23.10.2026.
//

import Foundation

enum CatalogSortOption: String, CaseIterable {

    // MARK: - Cases

    case name
    case nftCount

    // MARK: - Properties

    var title: String {
        switch self {
        case .name:
            String(localized: "Sort.byName")
        case .nftCount:
            String(localized: "Sort.byNftCount")
        }
    }
}
