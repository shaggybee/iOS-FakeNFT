//
//  CurrenciesServiceMock.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 28.10.2026.
//

import Foundation

actor CurrenciesServiceMock: CurrenciesServiceProtocol {
    func loadCurrencies() async throws -> [Currency] {
        try await Task.sleep(for: .seconds(1))
        
        return MockConstants.currencies
    }
}
