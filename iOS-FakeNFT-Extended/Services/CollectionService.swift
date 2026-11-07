//
//  CollectionService.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 26.10.2026.
//

import Foundation

// MARK: - CollectionServiceProtocol

protocol CollectionServiceProtocol: Sendable {
    func loadCollection(id: String) async throws -> NftCollection
}

// MARK: - CollectionServiceImpl

@MainActor
final class CollectionServiceImpl: CollectionServiceProtocol {

    // MARK: - Properties

    private let networkClient: NetworkClient

    // MARK: - Init

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    // MARK: - Public Methods

    func loadCollection(id: String) async throws -> NftCollection {
        let request = CollectionRequest(id: id)
        return try await networkClient.send(request: request)
    }
}
