//
//  OrderRequest.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 26.10.2026.
//

import Foundation

struct OrderRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }
}
