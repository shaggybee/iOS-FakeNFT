//
//  UpdateLikesRequest.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 26.10.2026.
//

import Foundation

struct UpdateLikesRequest: NetworkRequest {

    // MARK: - Properties

    let likes: [String]

    // MARK: - NetworkRequest

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
    }

    var httpMethod: HttpMethod { .put }

    var formParameters: [URLQueryItem]? {
        guard !likes.isEmpty else {
            return [URLQueryItem(name: "likes", value: "null")]
        }
        return likes.map { URLQueryItem(name: "likes", value: $0) }
    }
}
