//
//  CurrenciesRequest.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 28.10.2026.
//

import Foundation

struct CurrenciesRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/currencies")
    }
}
