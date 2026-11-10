//
//  MockNftService.swift
//  iOS-FakeNFT-Extended
//
//  Created by el on 06.11.2026.
//

import Foundation

struct MockNftService: NftService {
    
    func loadNft(id: String) async throws -> Nft {
        Nft(id: id, name: "NFT \(id)", images: [], rating: 2, price: 1.78, author: "Text")
    }
}

