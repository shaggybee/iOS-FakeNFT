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
    
    init(viewModel: ShoppingCartViewModel) {
        self.viewModel = viewModel
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
                if !viewModel.isErrorShown {
                    ErrorStateView(
                        message: "Не удалось получить элементы корзины",
                        onRetry: {
                            Task {
                                await viewModel.fetchNfts()
                            }
                        })
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.whitePrimary)
        .alert("Не удалось получить данные", isPresented: $viewModel.isErrorShown) {
            Button("Повторить") {
                Task {
                    await viewModel.fetchNfts()
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
        .task {
            await viewModel.fetchNfts()
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
                                // TODO добавить удаление NFT
                            }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .padding(.horizontal, 16)
            
            ShoppingCartSummaryView(
                count: viewModel.nfts.count,
                totalCost: viewModel.totalShoppingCartCost,
                onPayTap: {
                    // TODO добавить раутинг на экран оплаты
                }
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
            )
        )
    }
}
