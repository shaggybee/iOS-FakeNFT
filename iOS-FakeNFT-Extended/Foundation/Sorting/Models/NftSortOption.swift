//
//  NftSortOption.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 23.10.2026.
//

import Foundation

enum NftSortOption: String, CaseIterable {
    case price
    case rating
    case title

    var title: String {
        switch self {
        case .title:
            NSLocalizedString("Sorting.byTitle", comment: "")
        case .rating:
            NSLocalizedString("Sorting.byRating", comment: "")
        case .price:
            NSLocalizedString("Sorting.byPrice", comment: "")
        }
    }
}
