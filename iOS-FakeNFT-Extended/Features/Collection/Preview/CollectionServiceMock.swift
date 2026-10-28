//
//  CollectionServiceMock.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 28.10.2026.
//

import Foundation

struct CollectionServiceMock: CollectionServiceProtocol {

    // MARK: - Properties

    var collection = NftCollection.peachMock

    // MARK: - Public Methods

    func loadCollection(id: String) async throws -> NftCollection {
        collection
    }
}
