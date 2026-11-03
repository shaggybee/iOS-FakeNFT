#if DEBUG
import Foundation

// In-memory data for the Debug demo and isolated UI tests; never calls the API.
actor MockProfileService: ProfileService {
    private var profile: UserProfile
    private var failsFirstLoad: Bool
    private var failsFirstRemoval: Bool

    init(failsFirstLoad: Bool = false, unavailableWebsite: Bool = false, emptyNFTs: Bool = false,
         emptyFavorites: Bool = false, failsFirstRemoval: Bool = false) {
        self.failsFirstLoad = failsFirstLoad
        self.failsFirstRemoval = failsFirstRemoval
        profile = UserProfile(
            id: "1", name: "Студент Практикума", avatar: "",
            description: "Изучаю цифровое искусство и собираю коллекцию NFT.",
            website: unavailableWebsite ? "https://127.0.0.1:65534" : "https://practicum.yandex.ru/ios-developer",
            nfts: emptyNFTs ? [] : ["1", "2", "3"], likes: emptyFavorites ? [] : ["2", "5"]
        )
    }

    func loadProfile() async throws -> UserProfile {
        if failsFirstLoad {
            failsFirstLoad = false
            throw URLError(.notConnectedToInternet)
        }
        return profile
    }

    func updateProfile(fields: [String: String]) async throws -> UserProfile {
        profile = UserProfile(
            id: profile.id,
            name: fields["name"] ?? profile.name,
            avatar: fields["avatar"] ?? profile.avatar,
            description: fields["description"] ?? profile.description,
            website: fields["website"] ?? profile.website,
            nfts: profile.nfts, likes: profile.likes
        )
        return profile
    }

    func updateLikes(_ ids: [String]) async throws -> UserProfile {
        try Task.checkCancellation()
        if failsFirstRemoval {
            failsFirstRemoval = false
            throw URLError(.notConnectedToInternet)
        }
        profile = UserProfile(id: profile.id, name: profile.name, avatar: profile.avatar,
                              description: profile.description, website: profile.website,
                              nfts: profile.nfts, likes: ids)
        return profile
    }
}
#endif
