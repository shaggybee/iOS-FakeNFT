import Foundation

protocol ProfileNFTsService: Sendable {
    func loadNFTs(ids: [String]) async throws -> [Nft]
}

actor ProfileNFTsServiceImpl: ProfileNFTsService {
    private let nftService: any NftService

    init(nftService: any NftService) {
        self.nftService = nftService
    }

    func loadNFTs(ids: [String]) async throws -> [Nft] {
        var seen = Set<String>()
        let ids = ids.filter { seen.insert($0).inserted }
        guard !ids.isEmpty else { return [] }
        return try await ProfileConcurrentLoader.load(ids: ids) { [nftService] id in
            try await nftService.loadNft(id: id)
        }
    }
}

enum ProfileConcurrentLoader {
    private static let maximumConcurrentRequests = 4

    // Limit simultaneous requests and cancel the remaining work if any item fails.
    static func load<Value: Sendable>(
        ids: [String],
        operation: @escaping @Sendable (String) async throws -> Value
    ) async throws -> [Value] {
        try await withThrowingTaskGroup(of: Value.self) { group in
            var pending = ids.makeIterator()
            for _ in 0..<min(maximumConcurrentRequests, ids.count) {
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
