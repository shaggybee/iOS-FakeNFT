import Foundation

@Observable
@MainActor
final class ServicesAssembly {

    let nftService: NftService
    let collectionsService: CollectionsServiceProtocol
    let collectionService: CollectionServiceProtocol
    let likesService: LikesServiceProtocol
    let cartService: CartServiceProtocol

    init(
        networkClient: NetworkClient,
        nftStorage: NftStorage
    ) {
        nftService = NftServiceImpl(
            networkClient: networkClient,
            storage: nftStorage
        )
        collectionsService = CollectionsServiceImpl(networkClient: networkClient)
        collectionService = CollectionServiceImpl(networkClient: networkClient)
        likesService = LikesServiceImpl(networkClient: networkClient)
        cartService = CartServiceImpl(networkClient: networkClient)
    }
}
