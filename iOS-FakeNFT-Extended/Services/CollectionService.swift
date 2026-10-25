//
//  CollectionService.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 26.10.2026.
//

import Foundation

protocol CollectionService: Sendable {
    func loadCollection(id: String) async throws -> NftCollection
}

@MainActor
final class CollectionServiceImpl: CollectionService {

    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadCollection(id: String) async throws -> NftCollection {
        let request = CollectionRequest(id: id)
        return try await networkClient.send(request: request)
    }
}
