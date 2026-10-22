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

    private let collectionsService: CollectionsService
    private var nextPage = 0
    private var hasMorePages = true

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

    func sortButtonTapped() {}
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
            state = .loaded(collections)
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
            state = .loaded(collections + page.filter { !loadedIds.contains($0.id) })
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
}
