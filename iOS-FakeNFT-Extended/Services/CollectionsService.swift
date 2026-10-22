//
//  CollectionsService.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 22.10.2026.
//

import Foundation

protocol CollectionsService {
    func loadCollections(page: Int, size: Int) async throws -> [NftCollection]
}

@MainActor
final class CollectionsServiceImpl: CollectionsService {

    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadCollections(page: Int, size: Int) async throws -> [NftCollection] {
        let request = CollectionsRequest(page: page, size: size)
        return try await networkClient.send(request: request)
    }
}
