//
//  CatalogCellModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 23.10.2026.
//

import Foundation

struct CatalogCellModel: Identifiable, Equatable {
    let id: String
    let coverURL: URL?
    let title: String
}
