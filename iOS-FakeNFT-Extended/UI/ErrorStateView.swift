//
//  ErrorStateView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 20.10.2026.
//

import SwiftUI

struct ErrorStateView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text(message)
                .font(AppFont.bold17)
                .foregroundStyle(.blackPrimary)
                .multilineTextAlignment(.center)
            
            BaseButton(
                title: "Error.repeat",
                height: 44,
                action: onRetry
            )
            .frame(maxWidth: 200)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ErrorStateView(
        message: "Ошибка получения данных для экрана с каталогом NFT",
        onRetry: {}
    )
    .padding()
}
