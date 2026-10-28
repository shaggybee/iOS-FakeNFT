//
//  UpdateOrderRequest.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 26.10.2026.
//

import Foundation

struct UpdateOrderRequest: NetworkRequest {

    // MARK: - Properties

    let nftIDs: [String]

    // MARK: - NetworkRequest

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }

    var httpMethod: HttpMethod { .put }

    var formParameters: [URLQueryItem]? {
        guard !nftIDs.isEmpty else {
            return [URLQueryItem(name: "nfts", value: "null")]
        }
        return nftIDs.map { URLQueryItem(name: "nfts", value: $0) }
    }
}
