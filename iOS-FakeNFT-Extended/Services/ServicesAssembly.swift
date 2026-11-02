import Foundation

@Observable
@MainActor
final class ServicesAssembly {

    private let networkClient: NetworkClient
    private let nftStorage: NftStorage
    let profileService: any ProfileService
    let profileNFTsService: any ProfileNFTsService
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
                emptyNFTs: isUITesting && arguments.contains("--profile-empty-nfts")
            )
            profileNFTsService = MockProfileNFTsService(
                failsFirstLoad: isUITesting && arguments.contains("--profile-nfts-fail-first-load"),
                delaysRetry: isUITesting && arguments.contains("--profile-nfts-slow-retry")
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
        usesDemoProfileData = false
    }

    var nftService: NftService {
        NftServiceImpl(
            networkClient: networkClient,
            storage: nftStorage
        )
    }

}
