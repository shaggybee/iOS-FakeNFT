//
//  UserByIdRequest.swift
//  iOS-FakeNFT-Extended
//
//  Created by el on 30.10.2026.
//

import Foundation

struct UserByIdRequest: NetworkRequest {
    let id: String
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/users/\(id)")
    }
}
