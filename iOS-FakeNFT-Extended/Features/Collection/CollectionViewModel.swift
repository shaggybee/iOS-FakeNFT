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

    // MARK: - Properties

    private(set) var state: ViewState<CollectionScreenModel> = .idle
    var isLikeErrorPresented = false
    var isCartErrorPresented = false
    var isLoadErrorAlertPresented = false

    private let collectionId: String
    private let collectionService: CollectionServiceProtocol
    private let nftService: NftService
    private let likesService: LikesServiceProtocol
    private let cartService: ShoppingCartServiceProtocol
    private let router: CatalogRouterProtocol
    private var collection: NftCollection?
    private var nfts: [Nft] = []
    private var likes: Set<String> = []
    private var confirmedLikes: Set<String> = []
    private var likesSyncTask: Task<Void, Never>?
    private var cart: Set<String> = []
    private var confirmedCart: Set<String> = []
    private var cartSyncTask: Task<Void, Never>?

    // MARK: - Init

    init(
        collectionId: String,
        collectionService: CollectionServiceProtocol,
        nftService: NftService,
        likesService: LikesServiceProtocol,
        cartService: ShoppingCartServiceProtocol,
        router: CatalogRouterProtocol
    ) {
        self.collectionId = collectionId
        self.collectionService = collectionService
        self.nftService = nftService
        self.likesService = likesService
        self.cartService = cartService
        self.router = router
    }

    // MARK: - Public Methods

    func onAppear() async {
        if case .idle = state {
            await load()
        } else {
            async let cart: Void = reloadCart()
            async let likes: Void = reloadLikes()
            _ = await (cart, likes)
        }
    }

    func retryButtonTapped() {
        Task { await load() }
    }

    func authorTapped() {
        guard let website = collection?.website else { return }
        router.push(.webView(website))
    }

    func likeButtonTapped(_ nft: CollectionNftCellModel) {
        guard case .loaded = state else { return }

        if likes.contains(nft.id) {
            likes.remove(nft.id)
        } else {
            likes.insert(nft.id)
        }
        updateLoadedState()

        let likesToSave = likes
        let previousTask = likesSyncTask
        likesSyncTask = Task {
            await previousTask?.value
            await syncLikes(likesToSave)
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

        let cartToSave = cart
        let previousTask = cartSyncTask
        cartSyncTask = Task {
            await previousTask?.value
            await syncCart(cartToSave)
        }
    }
    
    func reloadCart() async {
        do {
            let cart = try await cartService.loadOrder()
            self.cart = cart
            self.confirmedCart = cart
            updateLoadedState()
        } catch {
            isCartErrorPresented = true
        }
    }

    func reloadLikes() async {
        await likesSyncTask?.value

        do {
            let likes = try await likesService.loadLikes()
            self.likes = likes
            self.confirmedLikes = likes
            updateLoadedState()
        } catch {
            isLikeErrorPresented = true
        }
    }
}

// MARK: - Private Methods

private extension CollectionViewModel {
    func load() async {
        state = .loading

        do {
            async let collection = collectionService.loadCollection(id: collectionId)
            async let likes = likesService.loadLikes()
            async let cart = cartService.loadOrder()
            let loadedCollection = try await collection
            nfts = try await nftService.loadNfts(ids: loadedCollection.nfts)
            self.likes = try await likes
            self.cart = try await cart
            self.collection = loadedCollection
            confirmedLikes = self.likes
            confirmedCart = self.cart
            updateLoadedState()
        } catch {
            guard !Task.isCancelled else {
                state = .idle
                return
            }
            state = .error(error)
            isLoadErrorAlertPresented = true
        }
    }

    func syncLikes(_ likesToSave: Set<String>) async {
        guard likesToSave != confirmedLikes else { return }

        do {
            try await likesService.updateLikes(likesToSave)
            confirmedLikes = likesToSave
        } catch {
            if likes == likesToSave {
                likes = confirmedLikes
                updateLoadedState()
            }
            isLikeErrorPresented = true
        }
    }

    func syncCart(_ cartToSave: Set<String>) async {
        guard cartToSave != confirmedCart else { return }

        do {
            try await cartService.updateCart(with: cartToSave)
            confirmedCart = cartToSave
        } catch {
            if cart == cartToSave {
                cart = confirmedCart
                updateLoadedState()
            }
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
            priceText: String(format: String(localized: "Collection.price"), nft.price.formatted()),
            isLiked: likes.contains(nft.id),
            isInCart: cart.contains(nft.id)
        )
    }
}
