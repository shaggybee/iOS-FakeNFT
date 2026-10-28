//
//  NftServiceMock.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 28.10.2026.
//

import Foundation

struct NftServiceMock: NftService {

    // MARK: - Properties

    var nfts = Nft.peachMocks

    // MARK: - Public Methods

    func loadNft(id: String) async throws -> Nft {
        guard let nft = nfts.first(where: { $0.id == id }) else {
            throw NetworkClientError.httpStatusCode(404)
        }
        return nft
    }

    func loadNfts(ids: [String]) async throws -> [Nft] {
        try ids.map { id in
            guard let nft = nfts.first(where: { $0.id == id }) else {
                throw NetworkClientError.httpStatusCode(404)
            }
            return nft
        }
    }
}
