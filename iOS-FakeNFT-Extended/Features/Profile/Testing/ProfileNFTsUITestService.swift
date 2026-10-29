#if DEBUG
import Foundation

actor ProfileNFTsUITestService: ProfileNFTsService {
    private var failsFirstLoad: Bool

    init(failsFirstLoad: Bool) { self.failsFirstLoad = failsFirstLoad }

    func loadNFTs(ids: [String]) async throws -> [ProfileNFT] {
        if failsFirstLoad {
            failsFirstLoad = false
            throw URLError(.notConnectedToInternet)
        }
        let author = NFTAuthor(id: "author", name: "John Doe")
        let items = [
            Nft(id: "1", images: [URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Pink/Lilo/1.png")].compactMap { $0 },
                name: "Lilo", rating: 3, price: Decimal(string: "1.78") ?? 0, author: author.id),
            Nft(id: "2", images: [URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Green/Spring/1.png")].compactMap { $0 },
                name: "Spring", rating: 5, price: Decimal(string: "3.25") ?? 0, author: author.id),
            Nft(id: "3", images: [URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/1.png")].compactMap { $0 },
                name: "April", rating: 4, price: Decimal(string: "0.99") ?? 0, author: author.id)
        ]
        return items.filter { ids.contains($0.id) }.map { ProfileNFT(nft: $0, author: author) }
    }
}
#endif
