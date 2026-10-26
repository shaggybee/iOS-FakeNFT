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
    var isLikeErrorPresented = false

    private let collectionId: String
    private let collectionService: CollectionService
    private let nftService: NftService
    private let likesService: LikesService
    private var collection: NftCollection?
    private var nfts: [Nft] = []
    private var likes: Set<String> = []
    private var confirmedLikes: Set<String> = []
    private var likesSyncTask: Task<Void, Never>?

    init(
        collectionId: String,
        collectionService: CollectionService,
        nftService: NftService,
        likesService: LikesService
    ) {
        self.collectionId = collectionId
        self.collectionService = collectionService
        self.nftService = nftService
        self.likesService = likesService
    }

    func onAppear() {
        guard case .idle = state else { return }
        Task { await load() }
    }

    func retryButtonTapped() {
        Task { await load() }
    }

    func likeButtonTapped(_ nft: CollectionNftCellModel) {
        guard case .loaded = state else { return }

        if likes.contains(nft.id) {
            likes.remove(nft.id)
        } else {
            likes.insert(nft.id)
        }
        updateLoadedState()

        let previousTask = likesSyncTask
        likesSyncTask = Task {
            await previousTask?.value
            await syncLikes()
        }
    }
}

private extension CollectionViewModel {
    func load() async {
        state = .loading

        do {
            async let collection = collectionService.loadCollection(id: collectionId)
            async let likes = likesService.loadLikes()
            let loadedCollection = try await collection
            nfts = try await loadNfts(ids: loadedCollection.nfts)
            self.likes = try await likes
            self.collection = loadedCollection
            confirmedLikes = self.likes
            updateLoadedState()
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

    func syncLikes() async {
        let likesToSave = likes
        guard likesToSave != confirmedLikes else { return }

        do {
            try await likesService.updateLikes(likesToSave)
            confirmedLikes = likesToSave
        } catch {
            likes = confirmedLikes
            updateLoadedState()
            isLikeErrorPresented = true
        }
    }

    func updateLoadedState() {
        guard let collection else { return }
        state = .loaded(
            CollectionScreenModel(
                collection: collection,
                nfts: nfts.map(cellModel)
            )
        )
    }

    func cellModel(_ nft: Nft) -> CollectionNftCellModel {
        CollectionNftCellModel(
            id: nft.id,
            imageURL: nft.images.first,
            name: nft.name,
            rating: nft.rating,
            price: nft.price,
            isLiked: likes.contains(nft.id),
            isInCart: false
        )
    }
}
