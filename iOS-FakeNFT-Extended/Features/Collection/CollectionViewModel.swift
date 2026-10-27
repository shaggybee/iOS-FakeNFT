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
    var isCartErrorPresented = false
    var presentedAuthorWebsite: URL?

    private let collectionId: String
    private let collectionService: CollectionService
    private let nftService: NftService
    private let likesService: LikesService
    private let cartService: CartService
    private var collection: NftCollection?
    private var nfts: [Nft] = []
    private var likes: Set<String> = []
    private var confirmedLikes: Set<String> = []
    private var likesSyncTask: Task<Void, Never>?
    private var cart: Set<String> = []
    private var confirmedCart: Set<String> = []
    private var cartSyncTask: Task<Void, Never>?

    init(
        collectionId: String,
        collectionService: CollectionService,
        nftService: NftService,
        likesService: LikesService,
        cartService: CartService
    ) {
        self.collectionId = collectionId
        self.collectionService = collectionService
        self.nftService = nftService
        self.likesService = likesService
        self.cartService = cartService
    }

    func onAppear() {
        guard case .idle = state else { return }
        Task { await load() }
    }

    func retryButtonTapped() {
        Task { await load() }
    }

    func authorTapped() {
        presentedAuthorWebsite = collection?.website
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

    func cartButtonTapped(_ nft: CollectionNftCellModel) {
        guard case .loaded = state else { return }

        if cart.contains(nft.id) {
            cart.remove(nft.id)
        } else {
            cart.insert(nft.id)
        }
        updateLoadedState()

        let previousTask = cartSyncTask
        cartSyncTask = Task {
            await previousTask?.value
            await syncCart()
        }
    }
}

private extension CollectionViewModel {
    func load() async {
        state = .loading

        do {
            async let collection = collectionService.loadCollection(id: collectionId)
            async let likes = likesService.loadLikes()
            async let cart = cartService.loadCart()
            let loadedCollection = try await collection
            nfts = try await nftService.loadNfts(ids: loadedCollection.nfts)
            self.likes = try await likes
            self.cart = try await cart
            self.collection = loadedCollection
            confirmedLikes = self.likes
            confirmedCart = self.cart
            updateLoadedState()
        } catch {
            state = .error(error)
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

    func syncCart() async {
        let cartToSave = cart
        guard cartToSave != confirmedCart else { return }

        do {
            try await cartService.updateCart(cartToSave)
            confirmedCart = cartToSave
        } catch {
            cart = confirmedCart
            updateLoadedState()
            isCartErrorPresented = true
        }
    }

    func updateLoadedState() {
        guard let collection else { return }
        state = .loaded(
            CollectionScreenModel(
                header: CollectionHeaderModel(
                    coverURL: collection.cover,
                    title: collection.name,
                    author: collection.author,
                    description: collection.description
                ),
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
            priceText: "\(nft.price.formatted()) ETH",
            isLiked: likes.contains(nft.id),
            isInCart: cart.contains(nft.id)
        )
    }
}
