//
//  ShoppingCartRootView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 19.10.2026.
//

import SwiftUI

struct ShoppingCartRootView: View {
    @State private var navigationPath: NavigationPath = NavigationPath()
    @State private var shoppingCartViewModel: ShoppingCartViewModel
    
    init(shoppingCartService: ShoppingCartServiceProtocol) {
        _shoppingCartViewModel = State(
            initialValue: ShoppingCartViewModel(
                shoppingCartService: shoppingCartService
            )
        )
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ShoppingCartView(
                viewModel: shoppingCartViewModel,
                onPayTap: {
                    navigationPath.append(ShoppingCartPath.payment)
                }
            )
            .navigationDestination(for: ShoppingCartPath.self) { path in
                switch path {
                case .payment:
                    ShoppingCartPaymentView()
                        .toolbar(.hidden, for: .tabBar)
                }
            }
        }
        .task {
            await shoppingCartViewModel.loadNfts()
        }
    }
}

#Preview {
    ShoppingCartRootView(shoppingCartService: ServicesAssemblyMock().shoppingCartService)
}
