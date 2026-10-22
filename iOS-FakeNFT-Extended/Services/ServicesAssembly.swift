import Foundation

@Observable
@MainActor
final class ServicesAssembly {

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
