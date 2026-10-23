//
//  NftCollection.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 21.10.2026.
//

import Foundation

struct NftCollection: Decodable, Identifiable, Hashable {
    let id: String
    let name: String
    let cover: URL?
    let nfts: [String]
    let description: String
    let author: String
    let website: URL?
}
