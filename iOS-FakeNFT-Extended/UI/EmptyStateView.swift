//
//  EmptyStateView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 19.10.2026.
//

import SwiftUI

struct EmptyStateView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(AppFont.bold17)
            .foregroundStyle(.blackPrimary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView(
        message: "Пустая корзина Пустая корзина Пустая корзина"
    )
    .padding(16)
}
