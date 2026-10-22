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
}
