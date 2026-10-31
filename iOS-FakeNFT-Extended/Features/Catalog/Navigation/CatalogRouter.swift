//
//  CatalogRouter.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 31.10.2026.
//

import Foundation

// MARK: - CatalogRouter

@Observable
@MainActor
final class CatalogRouter {

    // MARK: - Properties

    var path: [CatalogRoute] = []

    // MARK: - Public Methods

    func push(_ route: CatalogRoute) {
        path.append(route)
    }
}
