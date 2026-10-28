//
//  CollectionsRequest.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 22.10.2026.
//

import Foundation

struct CollectionsRequest: NetworkRequest {

    // MARK: - Properties

    let page: Int
    let size: Int

    // MARK: - NetworkRequest

    var endpoint: URL? {
        var components = URLComponents(string: "\(RequestConstants.baseURL)/api/v1/collections")
        components?.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "size", value: String(size))
        ]
        return components?.url
    }
}
