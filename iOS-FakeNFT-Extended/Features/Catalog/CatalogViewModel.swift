//
//  CatalogViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 21.10.2026.
//

import Foundation

@Observable
@MainActor
final class CatalogViewModel {
    private(set) var state: ViewState<[NftCollection]> = .idle
    private(set) var isLoadingNextPage = false
    private(set) var isNextPageFailed = false
    var isSortDialogPresented = false

    private let collectionsService: CollectionsService
    private var nextPage = 0
    private var hasMorePages = true
    private var sortOption: CatalogSortOption?

    init(collectionsService: CollectionsService) {
        self.collectionsService = collectionsService
    }

    func title(for collection: NftCollection) -> String {
        "\(collection.name) (\(collection.nfts.count))"
    }

    func onAppear() {
        guard case .idle = state else { return }
        Task { await loadFirstPage() }
    }

    func retryButtonTapped() {
        Task { await loadFirstPage() }
    }

    func collectionDidAppear(_ collection: NftCollection) {
        guard case .loaded(let collections) = state,
              collection.id == collections.last?.id,
              !isNextPageFailed else { return }
        Task { await loadNextPage() }
    }

    func nextPageRetryButtonTapped() {
        Task { await loadNextPage() }
    }

    func sortButtonTapped() {
        isSortDialogPresented = true
    }

    func sortOptionSelected(_ option: CatalogSortOption) {
        sortOption = option
        guard case .loaded(let collections) = state else { return }
        state = .loaded(sorted(collections))
    }
}

enum CatalogSortOption {
    case name
    case nftCount
}

private extension CatalogViewModel {
    enum Constants {
        static let pageSize = 10
    }

    func loadFirstPage() async {
        state = .loading
        nextPage = 0
        hasMorePages = true
        isNextPageFailed = false

        do {
            let collections = try await loadPage(nextPage)
            state = .loaded(sorted(collections))
        } catch {
            state = .error(error)
        }
    }

    func loadNextPage() async {
        guard case .loaded = state, hasMorePages, !isLoadingNextPage else { return }

        isLoadingNextPage = true
        isNextPageFailed = false
        defer { isLoadingNextPage = false }

        do {
            let page = try await loadPage(nextPage)
            guard case .loaded(let collections) = state else { return }
            let loadedIds = Set(collections.map(\.id))
            state = .loaded(sorted(collections + page.filter { !loadedIds.contains($0.id) }))
        } catch {
            isNextPageFailed = true
        }
    }

    func loadPage(_ page: Int) async throws -> [NftCollection] {
        let collections = try await collectionsService.loadCollections(page: page, size: Constants.pageSize)
        hasMorePages = collections.count == Constants.pageSize
        nextPage = page + 1
        return collections
    }

    func sorted(_ collections: [NftCollection]) -> [NftCollection] {
        switch sortOption {
        case .none:
            collections
        case .name:
            collections.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        case .nftCount:
            collections.sorted { $0.nfts.count > $1.nfts.count }
        }
    }
}
