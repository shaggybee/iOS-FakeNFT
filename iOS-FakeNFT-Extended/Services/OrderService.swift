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
    func pay(by currencyId: String) async throws
    func completeOrder() async throws
    func clear() async throws
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
        _ = try await networkClient.send(request: OrderUpdateRequest(nftIDs: nfts))
    }
    
    func pay(by currencyId: String) async throws {
        _ = try await networkClient.send(request: OrderPaymentRequest(currencyId: currencyId))
    }
    
    func completeOrder() async throws {
        let order: Order = try await networkClient.send(request: OrderRequest())
        
        _ = try await networkClient.send(request: OrderCompleteRequest(nftIDs: order.nfts))
    }
    
    func clear() async throws {
        _ = try await networkClient.send(request: OrderClearRequest())
    }
}
