//
//  ShoppingCartDeleteNftConfirmationView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 23.10.2026.
//

import SwiftUI

struct ShoppingCartDeleteNftConfirmationView: View {
    let nft: Nft
    
    var onDeleteTap: () -> Void
    var onCancelTap: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                NftLogoView(url: URL(string: nft.images.first ?? ""))
                    .frame(width: 108, height: 108)
                    .clipShape(.rect(cornerRadius: 12))
                
                Text("ShoppingCart.deleteNftConfirmation")
                    .font(AppFont.regular13)
                    .foregroundStyle(.blackPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 180)
            
            
            HStack(spacing: 8) {
                getButton("Button.delete", color: .redUniversal, action: onDeleteTap)
                getButton("Button.comeback", color: .whitePrimary, action: onCancelTap)
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func getButton(
        _ title: LocalizedStringKey,
        color: Color,
        action: @escaping () -> Void) -> some View {
            Button(action: action) {
                Text(title)
                    .font(AppFont.regular17)
                    .foregroundStyle(color)
                    .frame(width: 127, height: 44)
                    .background(.blackPrimary)
                    .clipShape(.rect(cornerRadius: 12))
            }
        }
}

#Preview {
    ShoppingCartDeleteNftConfirmationView(
        nft: Nft(
            id: "1",
            name: "тестовый 1",
            images: [""],
            description: "",
            rating: 1,
            price: 12,
            author: ""),
        onDeleteTap: {},
        onCancelTap: {}
    )
    .background(.ultraThinMaterial)
}
