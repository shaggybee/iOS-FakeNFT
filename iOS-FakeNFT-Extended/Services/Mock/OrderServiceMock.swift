//
//  OrderServiceMock.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 22.10.2026.
//

import Foundation

actor OrderServiceMock: OrderServiceProtocol {
    func loadOrder() async throws -> Order {
        try await Task.sleep(for: .seconds(1))
        
        return MockConstants.order
    }
    
    func updateOrder(nfts: [String]) async throws {
        // unused
    }
    
    func pay(by currencyId: String) async throws {
        try await Task.sleep(for: .seconds(1))
    }
    
    func clear() async throws {
        try await Task.sleep(for: .seconds(1))
    }
}
