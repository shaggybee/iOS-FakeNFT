import Foundation

@MainActor
protocol ServicesAssemblyProtocol {
    var nftService: NftService { get }
    var orderService: OrderServiceProtocol { get }
    var shoppingCartService: ShoppingCartServiceProtocol { get }
    var currenciesService: CurrenciesServiceProtocol { get }
}

@Observable
@MainActor
final class ServicesAssembly: ServicesAssemblyProtocol {
    private let networkClient: NetworkClient
    
    let nftService: NftService
    let collectionsService: CollectionsServiceProtocol
    let collectionService: CollectionServiceProtocol
    let likesService: LikesServiceProtocol
    let orderService: OrderServiceProtocol
    let shoppingCartService: ShoppingCartServiceProtocol
    
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
        orderService = OrderService(networkClient: networkClient)
        shoppingCartService = ShoppingCartService(
            orderService: orderService,
            nftService: nftService
        )
        self.networkClient = networkClient
    }
    
    var currenciesService: CurrenciesServiceProtocol {
        CurrenciesService(networkClient: networkClient)
    }
}
