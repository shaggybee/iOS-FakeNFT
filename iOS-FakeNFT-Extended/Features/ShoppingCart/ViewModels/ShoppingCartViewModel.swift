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
    var isFetchingNftsErrorShown: Bool = false
    var isDeletingNftErrorShown: Bool = false
    var sortOption: NftSortOption = .title
    var nftPendingDeletion: Nft?
    var isDeleting: Bool = false
    
    var nfts: [Nft] {
        guard case let .loaded(items) = viewState else {
            return []
        }
        
        return sort(nfts: items, by: sortOption)
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
    
    func loadNfts() async {
        await fetchNfts()
    }
    
    func apply(sort: NftSortOption) {
        sortOption = sort
    }
    
    func delete(nft: Nft) async {
        isDeleting = true
    
        do {
            let remainingNfts = nfts.filter { $0.id != nft.id }
            
            try await shoppingCartService.deleteNfts(except: remainingNfts.map({ $0.id }))
            
            viewState = .loaded(remainingNfts)
            nftPendingDeletion = nil
            isDeleting = false
        } catch {
            isDeleting = false
            isDeletingNftErrorShown = true
        }
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
    
    private func fetchNfts() async {
        viewState = .loading
        
        do {
            let result = try await shoppingCartService.loadShoppingCart()
            
            viewState = .loaded(result)
        } catch is CancellationError {
            //
        } catch {
            guard !Task.isCancelled else { return }
            
            isFetchingNftsErrorShown = true
            viewState = .error(nil)
        }
    }
    
    private func sort(nfts: [Nft], by option: NftSortOption) -> [Nft] {
        switch option {
        case .title: nfts.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        case .price: nfts.sorted { $0.price < $1.price }
        case .rating: nfts.sorted { $0.rating < $1.rating }
        }
    }
}
