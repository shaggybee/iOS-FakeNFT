//
//  Currency.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 28.10.2026.
//

import Foundation

struct Currency: Decodable, Sendable, Equatable {
    let id: String
    let title: String
    let name: String
    let imageURL: URL?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case name
        case imageURL = "image"
    }
}
