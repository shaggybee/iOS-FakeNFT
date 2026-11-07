import Foundation

struct ProfileFavoritesSnapshot: Sendable {
    let profile: UserProfile
    let items: [Nft]
}

protocol ProfileFavoritesService: Sendable {
    func loadFavorites() async throws -> ProfileFavoritesSnapshot
    func removeFavorite(id: String) async throws -> UserProfile
}

actor ProfileFavoritesServiceImpl: ProfileFavoritesService {
    private let profileService: any ProfileService
    private let nftService: any NftService
    private var isRemoving = false

    init(profileService: any ProfileService, nftService: any NftService) {
        self.profileService = profileService
        self.nftService = nftService
    }

    func loadFavorites() async throws -> ProfileFavoritesSnapshot {
        let profile = try await profileService.loadProfile()
        var seen = Set<String>()
        let ids = profile.likes.filter { seen.insert($0).inserted }
        let items = try await ProfileConcurrentLoader.load(ids: ids) { [nftService] id in
            try await nftService.loadNft(id: id)
        }
        let byID = Dictionary(items.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let ordered = try ids.map { id in
            guard let item = byID[id] else { throw NetworkClientError.parsingError }
            return item
        }
        return ProfileFavoritesSnapshot(profile: profile, items: ordered)
    }

    func removeFavorite(id: String) async throws -> UserProfile {
        // Actor methods can reenter across awaits: reject overlapping mutations.
        guard !isRemoving else { throw ProfileFavoritesError.busy }
        isRemoving = true
        defer { isRemoving = false }
        let current = try await profileService.loadProfile()
        try Task.checkCancellation()
        guard current.likes.contains(id) else { return current }
        var seen = Set<String>()
        let remaining = current.likes.filter { $0 != id && seen.insert($0).inserted }
        let updated = try await profileService.updateLikes(remaining)
        guard !updated.likes.contains(id) else { throw ProfileFavoritesError.removalRejected }
        return updated
    }
}

enum ProfileFavoritesError: Error {
    case busy
    case removalRejected
}
