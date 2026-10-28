//
//  CollectionsService.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 22.10.2026.
//

import Foundation

// MARK: - CollectionsServiceProtocol

protocol CollectionsServiceProtocol: Sendable {
    func loadCollections(page: Int, size: Int) async throws -> [NftCollection]
}

// MARK: - CollectionsServiceImpl

@MainActor
final class CollectionsServiceImpl: CollectionsServiceProtocol {

    // MARK: - Properties

    private let networkClient: NetworkClient

    // MARK: - Init

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    // MARK: - Public Methods

    func loadCollections(page: Int, size: Int) async throws -> [NftCollection] {
        let request = CollectionsRequest(page: page, size: size)
        return try await networkClient.send(request: request)
    }
}
