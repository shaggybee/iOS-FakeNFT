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
    let profileService: any ProfileService
    let profileNFTsService: any ProfileNFTsService
    let profileFavoritesService: any ProfileFavoritesService
    let usesDemoProfileData: Bool

    init(networkClient: NetworkClient, nftStorage: NftStorage, profileDataMode: ProfileDataMode = .current) {
        self.networkClient = networkClient
        nftService = NftServiceImpl(networkClient: networkClient, storage: nftStorage)
        collectionsService = CollectionsServiceImpl(networkClient: networkClient)
        collectionService = CollectionServiceImpl(networkClient: networkClient)
        likesService = LikesServiceImpl(networkClient: networkClient)
        orderService = OrderService(networkClient: networkClient)
        shoppingCartService = ShoppingCartService(orderService: orderService, nftService: nftService)
        #if DEBUG
        if profileDataMode != .live {
            let arguments = ProcessInfo.processInfo.arguments
            let isUITesting = profileDataMode == .uiTesting
            profileService = MockProfileService(
                failsFirstLoad: isUITesting && arguments.contains("--profile-fail-first-load"),
                unavailableWebsite: isUITesting && arguments.contains("--profile-unavailable-website"),
                emptyNFTs: isUITesting && arguments.contains("--profile-empty-nfts"),
                emptyFavorites: isUITesting && arguments.contains("--profile-empty-favorites"),
                failsFirstRemoval: isUITesting && arguments.contains("--profile-favorites-fail-first-removal")
            )
            profileNFTsService = MockProfileNFTsService(
                failsFirstLoad: isUITesting && arguments.contains("--profile-nfts-fail-first-load"),
                delaysRetry: isUITesting && arguments.contains("--profile-nfts-slow-retry")
            )
            profileFavoritesService = ProfileFavoritesServiceImpl(
                profileService: profileService,
                nftService: MockFavoriteNFTService(failsFirstLoad: isUITesting && arguments.contains("--profile-favorites-fail-first-load"))
            )
            usesDemoProfileData = !isUITesting
            return
        }
        #endif
        profileService = ProfileServiceImpl(networkClient: networkClient)
        profileNFTsService = ProfileNFTsServiceImpl(nftService: nftService)
        profileFavoritesService = ProfileFavoritesServiceImpl(profileService: profileService, nftService: nftService)
        usesDemoProfileData = false
    }

    var currenciesService: CurrenciesServiceProtocol { CurrenciesService(networkClient: networkClient) }
}
