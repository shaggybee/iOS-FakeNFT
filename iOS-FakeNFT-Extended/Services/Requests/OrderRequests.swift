//
//  OrderRequests.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 22.10.2026.
//

import Foundation

struct OrderRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }
}

struct OrderUpdateRequest: NetworkRequest {
    private struct OrderUpdateDTO: Encodable {
        let nfts: [String]
    }
    
    var httpMethod: HttpMethod { .put }

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }

    let dto: Encodable?

    init(nfts: [String]) {
        self.dto = OrderUpdateDTO(nfts: nfts)
    }
}
