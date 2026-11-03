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
        let author = NFTAuthor(id: "author", name: "John Doe")
        let items = [
            Nft(id: "1", images: [Bundle.main.url(forResource: "profile-demo-lilo", withExtension: "png")].compactMap { $0 },
                name: "Lilo", rating: 3, price: Decimal(string: "1.78") ?? 0, author: author.id),
            Nft(id: "2", images: [Bundle.main.url(forResource: "profile-demo-spring", withExtension: "png")].compactMap { $0 },
                name: "Spring", rating: 5, price: Decimal(string: "3.25") ?? 0, author: author.id),
            Nft(id: "3", images: [Bundle.main.url(forResource: "profile-demo-april", withExtension: "png")].compactMap { $0 },
                name: "April", rating: 4, price: Decimal(string: "0.99") ?? 0, author: author.id)
        ]
        return items.filter { ids.contains($0.id) }.map { ProfileNFT(nft: $0, author: author) }
    }
}
#endif
