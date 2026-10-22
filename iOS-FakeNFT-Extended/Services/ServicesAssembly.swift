import Foundation

@MainActor
protocol ServicesAssemblyProtocol {
    var nftService: NftService { get }
    var orderService: OrderServiceProtocol { get }
    var shoppingCartService: ShoppingCartServiceProtocol { get }
}

@Observable
@MainActor
final class ServicesAssembly: ServicesAssemblyProtocol {
    private let networkClient: NetworkClient
    private let nftStorage: NftStorage

    init(
        networkClient: NetworkClient,
        nftStorage: NftStorage
    ) {
        self.networkClient = networkClient
        self.nftStorage = nftStorage
    }

    var nftService: NftService {
        NftServiceImpl(
            networkClient: networkClient,
            storage: nftStorage
        )
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
