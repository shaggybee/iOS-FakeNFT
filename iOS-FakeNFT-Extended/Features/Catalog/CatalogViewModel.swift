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
    private let userDefaults: UserDefaults
    private var collections: [NftCollection] = []
    private var nextPage = 0
    private var hasMorePages = true
    private var sortOption: CatalogSortOption {
        didSet {
            userDefaults.set(sortOption.rawValue, forKey: Constants.sortOptionKey)
        }
    }

    init(
        collectionsService: CollectionsService,
        userDefaults: UserDefaults = .standard
    ) {
        self.collectionsService = collectionsService
        self.userDefaults = userDefaults
        self.sortOption = userDefaults.string(forKey: Constants.sortOptionKey)
            .flatMap(CatalogSortOption.init(rawValue:)) ?? .nftCount
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
              hasMorePages,
              !isLoadingNextPage,
              !isNextPageFailed,
              collections.suffix(Constants.prefetchThreshold).contains(where: { $0.id == cell.id }) else { return }
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
        static let prefetchThreshold = 3
        static let sortOptionKey = "catalogSortOption"
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
        isNextPageFailed = false

        do {
            let firstPage = 0
            let page = try await loadPage(firstPage)
            collections = sorted(page)
            updatePagination(afterLoading: firstPage, itemsCount: page.count)
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
            let pageNumber = nextPage
            let page = try await loadPage(pageNumber)
            guard case .loaded = state else { return }
            let loadedIds = Set(collections.map(\.id))
            collections = sorted(collections + page.filter { !loadedIds.contains($0.id) })
            updatePagination(afterLoading: pageNumber, itemsCount: page.count)
            state = .loaded(cellModels)
        } catch {
            isNextPageFailed = true
        }
    }

    func loadPage(_ page: Int) async throws -> [NftCollection] {
        try await collectionsService.loadCollections(page: page, size: Constants.pageSize)
    }

    func updatePagination(afterLoading page: Int, itemsCount: Int) {
        nextPage = page + 1
        hasMorePages = itemsCount == Constants.pageSize
    }

    func sorted(_ collections: [NftCollection]) -> [NftCollection] {
        switch sortOption {
        case .name:
            collections.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        case .nftCount:
            collections.sorted { $0.nfts.count > $1.nfts.count }
        }
    }
}
