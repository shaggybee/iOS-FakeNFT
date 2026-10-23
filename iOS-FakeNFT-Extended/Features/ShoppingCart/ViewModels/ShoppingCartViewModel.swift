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
    
    let sortOptions: [NftSortOption] = [.price, .rating, .title]
    let shoppingCartService: ShoppingCartServiceProtocol
    var isErrorShown: Bool = false
    var sortOption: NftSortOption = .title
    
    var nfts: [Nft] {
        guard case let .loaded(items) = viewState else {
            return []
        }
        
        return items
    }
    var isNftsListEmpty: Bool { nfts.isEmpty }
    var totalShoppingCartCost: Double {
        nfts.reduce(0) { result, nft in
            result + nft.price
        }
    }
    
    init(shoppingCartService: ShoppingCartServiceProtocol) {
        self.shoppingCartService = shoppingCartService
    }
    
    func fetchNfts() async {
        viewState = .loading
        
        do {
            let result = try await shoppingCartService.loadShoppingCart()
            
            viewState = .loaded(result)
        } catch is CancellationError {
            //
        } catch {
            guard !Task.isCancelled else { return }
            
            isErrorShown = true
            viewState = .error(nil)
        }
    }
    
    func apply(sort: NftSortOption) {
        sortOption = sort
    }
    
    func getPreparedCartCellModel(from nft: Nft) -> ShoppingCartCellModel {
        ShoppingCartCellModel(
            id: nft.id,
            name: nft.name,
            rating: nft.rating,
            price: nft.price,
            imageUrl: URL(string: nft.images.first ?? "")
        )
    }
}
