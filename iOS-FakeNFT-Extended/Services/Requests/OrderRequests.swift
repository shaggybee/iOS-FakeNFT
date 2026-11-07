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
    let nftIDs: [String]
    
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

struct OrderCompleteRequest: NetworkRequest {
    var httpMethod: HttpMethod { .post }
    
    let nftIDs: [String]

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }

    var formParameters: [URLQueryItem]? { nftIDs.map { URLQueryItem(name: "nfts", value: $0) }}
}

struct OrderClearRequest: NetworkRequest {
    var httpMethod: HttpMethod { .put }

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }

    var formParameters: [URLQueryItem]? { [URLQueryItem(name: "nfts", value: "null")] }
}

struct OrderPaymentRequest: NetworkRequest {
    let currencyId: String
    
    var httpMethod: HttpMethod { .get }

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1/payment/\(currencyId)")
    }
}
