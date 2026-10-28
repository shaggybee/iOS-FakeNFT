//
//  CartService.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 26.10.2026.
//

import Foundation

// MARK: - CartServiceProtocol

protocol CartServiceProtocol: Sendable {
    func loadCart() async throws -> Set<String>
    func updateCart(with nftIDs: Set<String>) async throws
}

// MARK: - CartServiceImpl

@MainActor
final class CartServiceImpl: CartServiceProtocol {

    // MARK: - Properties

    private let networkClient: NetworkClient

    // MARK: - Init

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    // MARK: - Public Methods

    func loadCart() async throws -> Set<String> {
        let order: OrderNfts = try await networkClient.send(request: OrderRequest())
        return Set(order.nfts)
    }

    func updateCart(with nftIDs: Set<String>) async throws {
        let request = UpdateOrderRequest(nftIDs: nftIDs.sorted())
        _ = try await networkClient.send(request: request)
    }
}
