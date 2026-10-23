//
//  ShoppingCartService.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 22.10.2026.
//

import Foundation

protocol ShoppingCartServiceProtocol: Sendable {
    func loadShoppingCart() async throws -> [Nft]
    func deleteNfts(except ids: [String]) async throws -> Void
}

actor ShoppingCartService: ShoppingCartServiceProtocol {
    private let orderService: OrderServiceProtocol
    private let nftService: NftService

    init(orderService: OrderServiceProtocol, nftService: NftService) {
        self.orderService = orderService
        self.nftService = nftService
    }

    func loadShoppingCart() async throws -> [Nft] {
        let order = try await orderService.loadOrder()
        
        return try await nftService.loadNfts(ids: order.nfts)
    }
    
    func deleteNfts(except ids: [String]) async throws {
        _ = try await orderService.updateOrder(nfts: ids)
    }
}
