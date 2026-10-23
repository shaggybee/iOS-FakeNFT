//
//  ShoppingCartRootView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 19.10.2026.
//

import SwiftUI

struct ShoppingCartRootView: View {
    // TODO как будет доступен API не забыть удалить и прокинуть действительный
    @Environment(ServicesAssemblyMock.self) private var services
    @State private var navigationPath: NavigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ShoppingCartView(
                viewModel: ShoppingCartViewModel(
                    shoppingCartService: services.shoppingCartService
                ),
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
    }
}

#Preview {
    ShoppingCartRootView()
}
