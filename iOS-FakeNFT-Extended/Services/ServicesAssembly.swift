import Foundation

@Observable
@MainActor
final class ServicesAssembly {

    private let networkClient: NetworkClient
    private let nftStorage: NftStorage
    let profileService: any ProfileService
    let profileNFTsService: any ProfileNFTsService
    let profileFavoritesService: any ProfileFavoritesService
    let usesDemoProfileData: Bool

    init(
        networkClient: NetworkClient,
        nftStorage: NftStorage,
        profileDataMode: ProfileDataMode = .current
    ) {
        self.networkClient = networkClient
        self.nftStorage = nftStorage
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
        profileNFTsService = ProfileNFTsServiceImpl(
            nftService: NftServiceImpl(networkClient: networkClient, storage: nftStorage),
            networkClient: networkClient
        )
        profileFavoritesService = ProfileFavoritesServiceImpl(
            profileService: profileService,
            nftService: NftServiceImpl(networkClient: networkClient, storage: nftStorage)
        )
        usesDemoProfileData = false
    }

    var nftService: NftService {
        NftServiceImpl(
            networkClient: networkClient,
            storage: nftStorage
        )
    }

}
