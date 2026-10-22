//
//  CatalogView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 21.10.2026.
//

import SwiftUI

struct CatalogView: View {
    @State private var viewModel: CatalogViewModel

    init(collectionsService: CollectionsService) {
        _viewModel = State(initialValue: CatalogViewModel(collectionsService: collectionsService))
    }

    var body: some View {
        NavigationStack {
            content
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        sortButton
                    }
                }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            LoadingView()
        case .error:
            ErrorStateView(
                message: "Не удалось загрузить коллекции",
                onRetry: viewModel.retryButtonTapped
            )
            .padding(.horizontal, Constants.horizontalPadding)
        case .loaded(let collections) where collections.isEmpty:
            EmptyStateView(message: "Коллекций пока нет")
                .padding(.horizontal, Constants.horizontalPadding)
        case .loaded(let collections):
            list(collections)
        }
    }

    private func list(_ collections: [NftCollection]) -> some View {
        List {
            ForEach(collections) { collection in
                CatalogCellView(
                    coverURL: collection.cover,
                    title: viewModel.title(for: collection)
                )
                .listRowInsets(Constants.rowInsets)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .onAppear {
                    viewModel.collectionDidAppear(collection)
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
                title: "Повторить",
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
            "Сортировка",
            isPresented: $viewModel.isSortDialogPresented,
            titleVisibility: .visible
        ) {
            Button("По названию") {
                viewModel.sortOptionSelected(.name)
            }
            Button("По количеству NFT") {
                viewModel.sortOptionSelected(.nftCount)
            }
            Button("Закрыть", role: .cancel) {}
        }
    }
}

private extension CatalogView {
    enum Constants {
        static let rowInsets = EdgeInsets(top: 0, leading: 16, bottom: 21, trailing: 16)
        static let horizontalPadding: CGFloat = 16
    }
}

#Preview {
    CatalogView(collectionsService: CollectionsServiceStub())
}
