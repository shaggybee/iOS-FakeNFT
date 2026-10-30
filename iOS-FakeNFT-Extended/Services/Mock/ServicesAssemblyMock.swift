//
//  ServicesAssemblyMock.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 22.10.2026.
//

import Foundation

@Observable
@MainActor
final class ServicesAssemblyMock: ServicesAssemblyProtocol {
    let nftService: NftService
    let orderService: OrderServiceProtocol
    let shoppingCartService: ShoppingCartServiceProtocol
    let currenciesService: CurrenciesServiceProtocol
    
    init() {
        nftService = NftServiceMock()
        orderService = OrderServiceMock()
        shoppingCartService = ShoppingCartServiceMock(
            orderService: orderService,
            nftService: nftService
        )
        currenciesService = CurrenciesServiceMock()
    }
}
