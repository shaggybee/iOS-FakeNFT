//
//  ShoppingCartViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 20.10.2026.
//

import Foundation

@MainActor
@Observable
final class ShoppingCartViewModel {
    private(set) var viewState: ViewState<[Nft]> = .idle
    
    var nfts: [Nft] = []
    
    var isNftsListEmpty: Bool { nfts.isEmpty }
    
    func fetchNfts() async {
        viewState = .loading
        
        nfts = []
    }
    
    func getPreparedCartCellModel(from nft: Nft) -> ShoppingCartCellModel {
        return ShoppingCartCellModel(
            id: nft.id,
            name: nft.name,
            rating: nft.rating,
            price: nft.price,
            imageUrl: URL(string: nft.images.first ?? "")
        )
    }
}
