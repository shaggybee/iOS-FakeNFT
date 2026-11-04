//
//  ShoppingCartService.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 22.10.2026.
//

import Foundation

protocol ShoppingCartServiceProtocol: Sendable {
    func loadOrder() async throws -> Set<String>
    func loadShoppingCart() async throws -> [Nft]
    func updateCart(with nftIDs: Set<String>) async throws
    func deleteNfts(except ids: [String]) async throws -> Void
    func pay(by currencyId: String) async throws
    func clear() async throws -> Void
}

actor ShoppingCartService: ShoppingCartServiceProtocol {
    private let orderService: OrderServiceProtocol
    private let nftService: NftService

    init(orderService: OrderServiceProtocol, nftService: NftService) {
        self.orderService = orderService
        self.nftService = nftService
    }
    
    func loadOrder() async throws -> Set<String> {
        let order = try await orderService.loadOrder()
        
        return Set(order.nfts)
    }

    func loadShoppingCart() async throws -> [Nft] {
        let order = try await orderService.loadOrder()
        
        return try await nftService.loadNfts(ids: order.nfts)
    }
    
    func updateCart(with nftIDs: Set<String>) async throws {
        _ = try await orderService.updateOrder(nfts: nftIDs.sorted())
    }
    
    func deleteNfts(except ids: [String]) async throws {
        try await orderService.updateOrder(nfts: ids)
    }
    
    func pay(by currencyId: String) async throws {
        try await orderService.pay(by: currencyId)
    }
    
    func clear() async throws {
        try await orderService.clear()
    }
}
