//
//  NftServiceMock.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 22.10.2026.
//

import Foundation

actor NftServiceMock: NftService {   
    func loadNft(id: String) async throws -> Nft {
        try await Task.sleep(for: .seconds(1))
        
        guard let nft = MockConstants.nfts.first(where: { $0.id == id }) else {
            throw URLError(.unknown)
        }
        
        return nft
    }
    
    func loadNfts(ids: [String]) async throws -> [Nft] {
        try await Task.sleep(for: .seconds(1))
        
        return MockConstants.nfts.filter { ids.contains($0.id) }
    }
}

