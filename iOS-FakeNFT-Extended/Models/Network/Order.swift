//
//  Order.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 22.10.2026.
//

import Foundation

struct Order: Decodable, Sendable, Equatable {
    let id: String
    let nfts: [String]
}
