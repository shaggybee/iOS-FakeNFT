#if DEBUG
import Foundation

actor MockProfileNFTsService: ProfileNFTsService {
    private var failsFirstLoad: Bool
    private let delaysRetry: Bool
    private var loadCount = 0

    init(failsFirstLoad: Bool = false, delaysRetry: Bool = false) {
        self.failsFirstLoad = failsFirstLoad
        self.delaysRetry = delaysRetry
    }

    func loadNFTs(ids: [String]) async throws -> [ProfileNFT] {
        loadCount += 1
        if delaysRetry && loadCount == 2 { try await Task.sleep(for: .seconds(60)) }
        try Task.checkCancellation()
        if failsFirstLoad {
            failsFirstLoad = false
            throw URLError(.notConnectedToInternet)
        }
        return ProfileMockNFTs.items.filter { ids.contains($0.id) }
    }
}
enum ProfileMockNFTs {
    static var items: [ProfileNFT] {
        let author = NFTAuthor(id: "author", name: "John Doe")
        let items = [
            Nft(id: "1", images: [Bundle.main.url(forResource: "profile-demo-lilo", withExtension: "png")].compactMap { $0 },
                name: "Lilo", rating: 3, price: 1.78, author: author.id),
            Nft(id: "2", images: [Bundle.main.url(forResource: "profile-demo-spring", withExtension: "png")].compactMap { $0 },
                name: "Spring", rating: 5, price: 3.25, author: author.id),
            Nft(id: "3", images: [Bundle.main.url(forResource: "profile-demo-april", withExtension: "png")].compactMap { $0 },
                name: "April", rating: 4, price: 0.99, author: author.id),
            Nft(id: "5", images: [Bundle.main.url(forResource: "profile-demo-lilo", withExtension: "png")].compactMap { $0 },
                name: "Charm", rating: 4, price: 2.10, author: author.id)
        ]
        return items.map { ProfileNFT(nft: $0, author: author) }
    }
}

actor MockFavoriteNFTService: NftService {
    private var failsFirstLoad: Bool
    init(failsFirstLoad: Bool = false) { self.failsFirstLoad = failsFirstLoad }

    func loadNft(id: String) async throws -> Nft {
        try Task.checkCancellation()
        if failsFirstLoad {
            failsFirstLoad = false
            throw URLError(.notConnectedToInternet)
        }
        guard let item = ProfileMockNFTs.items.first(where: { $0.id == id }) else {
            throw NetworkClientError.parsingError
        }
        return item.nft
    }
}
#endif
