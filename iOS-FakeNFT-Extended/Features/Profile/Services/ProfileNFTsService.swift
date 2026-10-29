import Foundation

protocol ProfileNFTsService: Sendable {
    func loadNFTs(ids: [String]) async throws -> [ProfileNFT]
}

actor ProfileNFTsServiceImpl: ProfileNFTsService {
    private let nftService: any NftService
    private let networkClient: any NetworkClient

    init(nftService: any NftService, networkClient: any NetworkClient) {
        self.nftService = nftService
        self.networkClient = networkClient
    }

    func loadNFTs(ids: [String]) async throws -> [ProfileNFT] {
        var seen = Set<String>()
        let ids = ids.filter { seen.insert($0).inserted }
        guard !ids.isEmpty else { return [] }
        let nfts = try await Self.load(ids: ids) { [nftService] id in
            try await nftService.loadNft(id: id)
        }
        let authorIDs = Array(Set(nfts.map(\.author)))
        let authors: [NFTAuthor] = try await Self.load(ids: authorIDs) { [networkClient] id in
            try await networkClient.send(request: ProfileNFTAuthorRequest(id: id))
        }
        let authorsByID = Dictionary(authors.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        return try nfts.map { nft in
            guard let author = authorsByID[nft.author] else { throw NetworkClientError.parsingError }
            return ProfileNFT(nft: nft, author: author)
        }
    }

    // Limit simultaneous requests and cancel the remaining work if any item fails.
    private static func load<Value: Sendable>(
        ids: [String],
        operation: @escaping @Sendable (String) async throws -> Value
    ) async throws -> [Value] {
        try await withThrowingTaskGroup(of: Value.self) { group in
            var pending = ids.makeIterator()
            for _ in 0..<min(4, ids.count) {
                if let id = pending.next() { group.addTask { try await operation(id) } }
            }
            var values: [Value] = []
            for try await value in group {
                try Task.checkCancellation()
                values.append(value)
                if let id = pending.next() { group.addTask { try await operation(id) } }
            }
            return values
        }
    }
}

struct ProfileNFTAuthorRequest: NetworkRequest {
    let id: String

    var endpoint: URL? {
        let allowed = CharacterSet.urlPathAllowed.subtracting(CharacterSet(charactersIn: "/?#"))
        guard let id = id.addingPercentEncoding(withAllowedCharacters: allowed) else { return nil }
        return URL(string: RequestConstants.baseURL + "/api/v1/users/" + id)
    }
}
