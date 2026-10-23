//
//  CollectionsRequest.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 22.10.2026.
//

import Foundation

struct CollectionsRequest: NetworkRequest {

    let page: Int
    let size: Int

    var endpoint: URL? {
        var components = URLComponents(string: "\(RequestConstants.baseURL)/api/v1/collections")
        components?.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "size", value: String(size))
        ]
        return components?.url
    }
}
