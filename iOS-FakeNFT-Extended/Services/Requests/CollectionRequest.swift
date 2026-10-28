//
//  CollectionRequest.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 26.10.2026.
//

import Foundation

struct CollectionRequest: NetworkRequest {

    // MARK: - Properties

    let id: String

    // MARK: - NetworkRequest

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/collections/\(id)")
    }
}
