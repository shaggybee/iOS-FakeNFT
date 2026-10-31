//
//  ShoppingCartRootViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 01.11.2026.
//

import Foundation

@MainActor
@Observable
final class ShoppingCartRootViewModel {
    let agreementUrl: String = "https://practicum.yandex.ru"
    
    var nftsLoadToken: UUID = UUID()
    
    func reloadNfts() {
        nftsLoadToken = UUID()
    }
}
