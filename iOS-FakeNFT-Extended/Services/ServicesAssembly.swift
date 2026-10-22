import Foundation

@MainActor
protocol ServicesAssemblyProtocol {
    var nftService: NftService { get }
    var orderService: OrderServiceProtocol { get }
    var shoppingCartService: ShoppingCartServiceProtocol { get }
}

@Observable
@MainActor
final class ServicesAssembly {


final class ServicesAssembly: ServicesAssemblyProtocol {
    private let networkClient: NetworkClient
    private let nftStorage: NftStorage

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
    
    var orderService: OrderServiceProtocol {
        OrderService(networkClient: networkClient)
    }

    var shoppingCartService: ShoppingCartServiceProtocol {
        ShoppingCartService(
            orderService: orderService,
            nftService: nftService
        )
    }
}
