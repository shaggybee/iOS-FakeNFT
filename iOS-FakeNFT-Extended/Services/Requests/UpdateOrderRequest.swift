//
//  UpdateOrderRequest.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 26.10.2026.
//

import Foundation

struct UpdateOrderRequest: NetworkRequest {

    let nfts: [String]

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }

    var httpMethod: HttpMethod { .put }

    var formParameters: [URLQueryItem]? {
        // API не принимает пустой массив: чтобы очистить корзину, нужно передать "null"
        guard !nfts.isEmpty else {
            return [URLQueryItem(name: "nfts", value: "null")]
        }
        return nfts.map { URLQueryItem(name: "nfts", value: $0) }
    }
}
