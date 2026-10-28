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
    let image: URL?
}
