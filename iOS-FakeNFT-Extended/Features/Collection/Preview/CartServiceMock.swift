//
//  CartServiceMock.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 28.10.2026.
//

import Foundation

actor CartServiceMock: CartServiceProtocol {

    // MARK: - Properties

    static let shared = CartServiceMock()

    private var nftIDs: Set<String>

    // MARK: - Init

    init(nftIDs: Set<String> = ["0", "1", "2"]) {
        self.nftIDs = nftIDs
    }

    // MARK: - Public Methods

    func loadCart() async throws -> Set<String> {
        nftIDs
    }

    func updateCart(with nftIDs: Set<String>) async throws {
        self.nftIDs = nftIDs
    }
}
