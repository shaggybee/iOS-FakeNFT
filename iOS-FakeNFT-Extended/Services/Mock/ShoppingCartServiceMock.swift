//
//  ShoppingCartServiceMock.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 22.10.2026.
//

import Foundation

actor ShoppingCartServiceMock: ShoppingCartServiceProtocol {
    private let orderService: OrderServiceProtocol
    private let nftService: NftService
    
    private var nftIDs: Set<String> = ["0", "1", "2"]
    
    var loadedNfts: [Nft] = []
    var isStorageInit: Bool = false
    
    init(orderService: OrderServiceProtocol, nftService: NftService) {
        self.orderService = orderService
        self.nftService = nftService
    }
    
    func loadShoppingCart() async throws -> [Nft] {
        if isStorageInit {
            try await Task.sleep(for: .seconds(2))
            
            return loadedNfts
        }
        
        let order = try await orderService.loadOrder()
        let nfts = try await nftService.loadNfts(ids: order.nfts)
        
        loadedNfts = nfts
        isStorageInit = true
        
        return nfts
    }
    
    func deleteNfts(except ids: [String]) async throws {
        loadedNfts = loadedNfts.filter { ids.contains($0.id) }
    }
    
    func pay(by currencyId: String) async throws {
        try await orderService.pay(by: currencyId)
    }
    
    func clear() async throws {
        _ = try await orderService.clear()
        
        loadedNfts = []
    }
    
    func loadOrder() async throws -> Set<String> {
        nftIDs
    }

    func updateCart(with nftIDs: Set<String>) async throws {
        self.nftIDs = nftIDs
    }
}
