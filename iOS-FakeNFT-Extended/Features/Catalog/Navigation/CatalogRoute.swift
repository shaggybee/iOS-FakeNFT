//
//  CatalogRoute.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 31.10.2026.
//

import Foundation

// MARK: - CatalogRoute

enum CatalogRoute: Hashable {
    case collection(id: String)
    case webView(URL)
}
