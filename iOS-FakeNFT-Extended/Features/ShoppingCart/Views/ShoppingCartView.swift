//
//  ShoppingCartView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 19.10.2026.
//

import SwiftUI

struct ShoppingCartView: View {
    @State private var viewModel: ShoppingCartViewModel
    
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
                        .padding(.horizontal, 16)
                }
            case .error:
                ErrorStateView(message: "Не удалось получить элементы корзины", onRetry: {
                    // TODO добавить обновление списка
                })
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.whitePrimary)
        .task {
            await viewModel.fetchNfts()
        }
    }
    
    private var content: some View {
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
    }
}

#Preview {
    ShoppingCartView(viewModel: ShoppingCartViewModel())
}
