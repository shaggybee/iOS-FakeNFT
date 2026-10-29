#if DEBUG
import Foundation

// Только для детерминированного запуска UI-тестов с явным launch argument.
// В обычном запуске приложение всегда использует настоящий сетевой сервис.
actor ProfileUITestService: ProfileService {
    private var profile: UserProfile
    private var failsFirstLoad: Bool

    init(failsFirstLoad: Bool, unavailableWebsite: Bool = false) {
        self.failsFirstLoad = failsFirstLoad
        profile = UserProfile(
            id: "1", name: "Студент Практикума", avatar: "",
            description: "Изучаю цифровое искусство и собираю коллекцию NFT.",
            website: unavailableWebsite ? "https://127.0.0.1:65534" : "https://practicum.yandex.ru/ios-developer",
            nfts: ["1", "2", "3"], likes: ["4", "5"]
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
}
#endif
