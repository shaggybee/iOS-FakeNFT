//
//  OrderService.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 22.10.2026.
//

import Foundation

protocol OrderServiceProtocol: Sendable {
    func loadOrder() async throws -> Order
    func updateOrder(nfts: [String]) async throws
}

actor OrderService: OrderServiceProtocol {

    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadOrder() async throws -> Order {
        try await networkClient.send(request: OrderRequest())
    }
    
    func updateOrder(nfts: [String]) async throws {
        _ = try await networkClient.send(request: OrderUpdateRequest(nfts: nfts))
    }
}
