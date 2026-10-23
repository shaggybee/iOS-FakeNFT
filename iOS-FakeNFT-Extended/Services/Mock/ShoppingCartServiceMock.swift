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
}
