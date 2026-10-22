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
    
    var body: some View {
        // TODO в последующих задачах реализовать навигацию
        ShoppingCartView(
            viewModel: ShoppingCartViewModel(
                shoppingCartService: services.shoppingCartService
            )
        )
    }
}

#Preview {
    ShoppingCartRootView()
}
