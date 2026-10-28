//
//  ShoppingCartRootView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 19.10.2026.
//

import SwiftUI

struct ShoppingCartRootView: View {
    private var services: ServicesAssemblyProtocol
    
    @State private var navigationPath: NavigationPath = NavigationPath()
    @State private var shoppingCartViewModel: ShoppingCartViewModel
    
    init(services: ServicesAssemblyProtocol) {
        self.services = services
        
        _shoppingCartViewModel = State(
            initialValue: ShoppingCartViewModel(
                shoppingCartService: services.shoppingCartService
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
                    let shoppingCartPaymentViewModel = ShoppingCartPaymentViewModel(currenciesService: services.currenciesService)
                    
                    ShoppingCartPaymentView(viewModel: shoppingCartPaymentViewModel)
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
    ShoppingCartRootView(services: ServicesAssemblyMock())
}
