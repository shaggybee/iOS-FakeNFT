//
//  CatalogRouter.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 31.10.2026.
//

import Foundation

// MARK: - CatalogRouterProtocol

@MainActor
protocol CatalogRouterProtocol: AnyObject {
    func push(_ route: CatalogRoute)
}

// MARK: - CatalogRouter

@Observable
@MainActor
final class CatalogRouter: CatalogRouterProtocol {

    // MARK: - Properties

    var path: [CatalogRoute] = []

    // MARK: - Public Methods

    func push(_ route: CatalogRoute) {
        path.append(route)
    }
}
