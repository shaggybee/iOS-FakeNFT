//
//  CurrenciesService.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 28.10.2026.
//

import Foundation

protocol CurrenciesServiceProtocol: Sendable {
    func loadCurrencies() async throws -> [Currency]
}

actor CurrenciesService: CurrenciesServiceProtocol {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadCurrencies() async throws -> [Currency] {
        try await networkClient.send(request: CurrenciesRequest())
    }
}
