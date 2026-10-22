//
//  CatalogView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 21.10.2026.
//

import SwiftUI

struct CatalogView: View {
    @State private var viewModel: CatalogViewModel

    init(viewModel: CatalogViewModel) {
        _viewModel = State(initialValue: viewModel)
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
        case .empty:
            EmptyStateView(message: "Коллекций пока нет")
                .padding(.horizontal, Constants.horizontalPadding)
        case .loaded(let cells):
            list(cells)
        }
    }

    private func list(_ cells: [CatalogCellModel]) -> some View {
        List {
            ForEach(cells) { cell in
                CatalogCellView(
                    coverURL: cell.coverURL,
                    title: cell.title
                )
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
            ForEach(CatalogSortOption.allCases, id: \.self) { option in
                Button(option.title) {
                    viewModel.sortOptionSelected(option)
                }
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
    CatalogView(viewModel: CatalogViewModel(collectionsService: CollectionsServiceStub()))
}
