//
//  CartService.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 26.10.2026.
//

import Foundation

protocol CartService: Sendable {
    func loadCart() async throws -> Set<String>
    func updateCart(_ nfts: Set<String>) async throws
}

@MainActor
final class CartServiceImpl: CartService {

    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadCart() async throws -> Set<String> {
        let order: OrderNfts = try await networkClient.send(request: OrderRequest())
        return Set(order.nfts)
    }

    func updateCart(_ nfts: Set<String>) async throws {
        let request = UpdateOrderRequest(nfts: nfts.sorted())
        _ = try await networkClient.send(request: request)
    }
}
