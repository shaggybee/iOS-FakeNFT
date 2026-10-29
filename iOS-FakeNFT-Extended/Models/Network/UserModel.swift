//
//  UserModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by el on 23.10.2026.
//

import Foundation

struct User: Decodable {
    let id: String
    let name: String
    let avatar: String
    let description: String
    let website: String
    let nfts: [String]
    let rating: String
}
