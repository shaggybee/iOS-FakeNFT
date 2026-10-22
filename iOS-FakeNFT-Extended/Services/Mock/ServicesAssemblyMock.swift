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
    var nftService: NftService {
        NftServiceMock()
    }
    
    var orderService: OrderServiceProtocol {
        OrderServiceMock()
    }

    var shoppingCartService: ShoppingCartServiceProtocol {
        ShoppingCartServiceMock(
            orderService: orderService,
            nftService: nftService
        )
    }
}
