//
//  CollectionViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 26.10.2026.
//

import Foundation

@Observable
@MainActor
final class CollectionViewModel {
    private(set) var state: ViewState<CollectionScreenModel> = .idle

    private let collectionId: String
    private let collectionService: CollectionService
    private let nftService: NftService

    init(
        collectionId: String,
        collectionService: CollectionService,
        nftService: NftService
    ) {
        self.collectionId = collectionId
        self.collectionService = collectionService
        self.nftService = nftService
    }

    func onAppear() {
        guard case .idle = state else { return }
        Task { await load() }
    }

    func retryButtonTapped() {
        Task { await load() }
    }
}

private extension CollectionViewModel {
    func load() async {
        state = .loading

        do {
            let collection = try await collectionService.loadCollection(id: collectionId)
            let nfts = try await loadNfts(ids: collection.nfts)
            state = .loaded(
                CollectionScreenModel(
                    collection: collection,
                    nfts: nfts.map(cellModel)
                )
            )
        } catch {
            state = .error(error)
        }
    }

    func loadNfts(ids: [String]) async throws -> [Nft] {
        try await withThrowingTaskGroup(of: (Int, Nft).self) { group in
            for (index, id) in ids.enumerated() {
                group.addTask { [nftService] in
                    (index, try await nftService.loadNft(id: id))
                }
            }

            var nfts = [Nft?](repeating: nil, count: ids.count)
            for try await (index, nft) in group {
                nfts[index] = nft
            }
            return nfts.compactMap { $0 }
        }
    }

    func cellModel(_ nft: Nft) -> CollectionNftCellModel {
        CollectionNftCellModel(
            id: nft.id,
            imageURL: nft.images.first,
            name: nft.name,
            rating: nft.rating,
            price: nft.price,
            isLiked: false,
            isInCart: false
        )
    }
}
