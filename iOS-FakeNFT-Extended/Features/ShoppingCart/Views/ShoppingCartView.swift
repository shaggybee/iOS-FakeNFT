//
//  ShoppingCartView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 19.10.2026.
//

import SwiftUI

struct ShoppingCartView: View {
    private static let sortOptionKey = "shoppingCart.sortOptionKey"
    
    @State private var viewModel: ShoppingCartViewModel
    @State private var isSortSheetPresented = false
    @AppStorage(Self.sortOptionKey) private var sortOption: NftSortOption = .title
    
    let onPayTap: () -> Void
    
    init(viewModel: ShoppingCartViewModel, onPayTap: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onPayTap = onPayTap
    }
    
    var body: some View {
        ZStack {
            switch viewModel.viewState {
            case .idle, .loading:
                LoadingView()
            case .loaded:
                if viewModel.isNftsListEmpty {
                    EmptyStateView(message: "Корзина пуста")
                } else {
                    content
                }
            case .error:
                if !viewModel.isFetchingNftsErrorShown {
                    ErrorStateView(
                        message: "Не удалось получить элементы корзины",
                        onRetry: {
                            Task {
                                await viewModel.loadNfts()
                            }
                        })
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.whitePrimary)
        .alert("Не удалось получить данные", isPresented: $viewModel.isFetchingNftsErrorShown) {
            Button("Повторить") {
                Task {
                    await viewModel.loadNfts()
                }
            }
            Button("Отмена", role: .cancel) { }
        }
        .toolbar {
            if !viewModel.isNftsListEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isSortSheetPresented = true
                    } label: {
                        Image(.sort40)
                            .foregroundStyle(.blackPrimary)
                            .frame(width: 42, height: 42)
                    }
                }
            }
        }
        .confirmationDialog("Сортировка", isPresented: $isSortSheetPresented, titleVisibility: .visible) {
            ForEach(viewModel.sortOptions, id: \.self) { option in
                Button(option.title) {
                    sortOption = option
                }
            }
            
            Button("Закрыть", role: .cancel) { }
        }
        .fullScreenCover(item: $viewModel.nftPendingDeletion) { nft in
            ZStack {
                ShoppingCartDeleteNftConfirmationView(
                    nft: nft,
                    onDeleteTap: {
                        Task {
                            await viewModel.delete(nft: nft)
                        }
                    },
                    onCancelTap: {
                        viewModel.nftPendingDeletion = nil
                    }
                )
                .disabled(viewModel.isDeleting)
                
                if (viewModel.isDeleting) {
                    BlockingProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .alert("Не удалось удалить NFT", isPresented: $viewModel.isDeletingNftErrorShown) {
                Button("Повторить") {
                    Task {
                        guard let deletingNft = viewModel.nftPendingDeletion else {
                            return
                        }
                        
                        await viewModel.delete(nft: deletingNft)
                    }
                }
                Button("Отмена", role: .cancel) {
                    viewModel.isDeleting = false
                }
            }
            .presentationBackground(.ultraThinMaterial)
        }
        .onChange(of: sortOption, initial: true) {
            viewModel.apply(sort: $1)
        }
    }
    
    private var content: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.nfts, id: \.id) { nft in
                        ShoppingCartCellView(
                            model: viewModel.getPreparedCartCellModel(from: nft)) {
                                viewModel.nftPendingDeletion = nft
                            }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .padding(.horizontal, 16)
            
            ShoppingCartSummaryView(
                count: viewModel.nfts.count,
                totalCost: viewModel.totalShoppingCartCost,
                onPayTap: onPayTap
            )
        }
    }
}

#Preview {
    let servicesAssembly = ServicesAssemblyMock()
    
    NavigationStack {
        ShoppingCartView(
            viewModel: ShoppingCartViewModel(
                shoppingCartService: servicesAssembly.shoppingCartService
            ),
            onPayTap: {}
        )
    }
}
