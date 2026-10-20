//
//  ShoppingCartRootView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 19.10.2026.
//

import SwiftUI

struct ShoppingCartRootView: View {
    var body: some View {
        // TODO в последующих задачах реализовать навигацию
        ShoppingCartView(viewModel: ShoppingCartViewModel())
    }
}

#Preview {
    ShoppingCartRootView()
}
