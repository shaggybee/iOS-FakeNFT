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
    private(set) var state: ViewState<[CatalogCellModel]> = .idle
    private(set) var isLoadingNextPage = false
    private(set) var isNextPageFailed = false
    var isSortDialogPresented = false

    private let collectionsService: CollectionsService
    private var collections: [NftCollection] = []
    private var nextPage = 0
    private var hasMorePages = true
    private var sortOption: CatalogSortOption?

    init(collectionsService: CollectionsService) {
        self.collectionsService = collectionsService
    }

    func onAppear() {
        guard case .idle = state else { return }
        Task { await loadFirstPage() }
    }

    func retryButtonTapped() {
        Task { await loadFirstPage() }
    }

    func cellDidAppear(_ cell: CatalogCellModel) {
        guard case .loaded = state,
              cell.id == collections.last?.id,
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
        guard case .loaded = state else { return }
        collections = sorted(collections)
        state = .loaded(cellModels)
    }
}

private extension CatalogViewModel {
    enum Constants {
        static let pageSize = 10
    }

    var cellModels: [CatalogCellModel] {
        collections.map { collection in
            CatalogCellModel(
                id: collection.id,
                coverURL: collection.cover,
                title: "\(collection.name) (\(collection.nfts.count))"
            )
        }
    }

    func loadFirstPage() async {
        state = .loading
        nextPage = 0
        hasMorePages = true
        isNextPageFailed = false

        do {
            collections = sorted(try await loadPage(nextPage))
            state = collections.isEmpty ? .empty : .loaded(cellModels)
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
            guard case .loaded = state else { return }
            let loadedIds = Set(collections.map(\.id))
            collections = sorted(collections + page.filter { !loadedIds.contains($0.id) })
            state = .loaded(cellModels)
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
