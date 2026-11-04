//
//  CatalogView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 21.10.2026.
//

import SwiftUI

// MARK: - CatalogView

struct CatalogView: View {

    // MARK: - Properties

    @State private var viewModel: CatalogViewModel
    @Bindable private var router: CatalogRouter
    private let makeCollectionViewModel: (String) -> CollectionViewModel

    // MARK: - Init

    init(
        viewModel: CatalogViewModel,
        router: CatalogRouter,
        makeCollectionViewModel: @escaping (String) -> CollectionViewModel
    ) {
        _viewModel = State(initialValue: viewModel)
        self.router = router
        self.makeCollectionViewModel = makeCollectionViewModel
    }

    // MARK: - Body

    var body: some View {
        NavigationStack(path: $router.path) {
            content
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        sortButton
                    }
                }
                .navigationDestination(for: CatalogRoute.self, destination: destination)
        }
        .task {
            await viewModel.onAppear()
        }
        .loadErrorAlert(
            isPresented: $viewModel.isLoadErrorAlertPresented,
            onRetry: viewModel.loadErrorAlertRetryTapped
        )
    }

    // MARK: - Private Views

    @ViewBuilder
    private func destination(_ route: CatalogRoute) -> some View {
        switch route {
        case .collection(let id):
            CollectionView(viewModel: makeCollectionViewModel(id))
        case .webView(let url):
            WebView(url: url)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            CatalogSkeletonView()
        case .error:
            ErrorStateView(
                message: String(localized: "Catalog.loadingError"),
                onRetry: viewModel.retryButtonTapped
            )
            .padding(.horizontal, Constants.horizontalPadding)
        case .empty:
            EmptyStateView(message: String(localized: "Catalog.empty"))
                .padding(.horizontal, Constants.horizontalPadding)
        case .loaded(let cells):
            list(cells)
        }
    }

    private func list(_ cells: [CatalogCellModel]) -> some View {
        List {
            ForEach(cells) { cell in
                Button {
                    viewModel.cellTapped(cell)
                } label: {
                    CatalogCellView(model: cell)
                }
                .buttonStyle(.plain)
                .listRowInsets(Constants.rowInsets)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .onAppear {
                    viewModel.cellDidAppear(cell)
                }
            }

            nextPageFooter
                .frame(maxWidth: .infinity)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    private var nextPageFooter: some View {
        if viewModel.isLoadingNextPage {
            ProgressView()
                .tint(.blackPrimary)
        } else if viewModel.isNextPageFailed {
            BaseButton(
                title: String(localized: "Error.retry"),
                height: 44,
                action: viewModel.nextPageRetryButtonTapped
            )
            .frame(maxWidth: 200)
        }
    }

    private var sortButton: some View {
        Button {
            viewModel.sortButtonTapped()
        } label: {
            Image(.sort40)
        }
        .tint(.blackPrimary)
        .confirmationDialog(
            String(localized: "Sort.title"),
            isPresented: $viewModel.isSortDialogPresented,
            titleVisibility: .visible
        ) {
            ForEach(CatalogSortOption.allCases, id: \.self) { option in
                Button(option.title) {
                    viewModel.sortOptionSelected(option)
                }
            }
            Button(String(localized: "Common.close"), role: .cancel) {}
        }
    }
}

// MARK: - Constants

private extension CatalogView {
    enum Constants {
        static let rowInsets = EdgeInsets(top: 0, leading: 16, bottom: 21, trailing: 16)
        static let horizontalPadding: CGFloat = 16
    }
}

// MARK: - Preview

#Preview {
    let router = CatalogRouter()

    CatalogView(
        viewModel: CatalogViewModel(collectionsService: CollectionsServiceStub(), router: router),
        router: router,
        makeCollectionViewModel: { collectionId in
            CollectionViewModel(
                collectionId: collectionId,
                collectionService: CollectionServiceMock(),
                nftService: NftServiceMock(),
                likesService: LikesServiceMock(),
                cartService: ShoppingCartServiceMock(
                    orderService: OrderServiceMock(),
                    nftService: NftServiceMock()
                ),
                router: router
            )
        }
    )
}
