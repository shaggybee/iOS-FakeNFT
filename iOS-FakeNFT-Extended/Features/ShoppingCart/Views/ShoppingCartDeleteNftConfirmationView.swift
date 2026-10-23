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
                nftLogo
                    .frame(width: 108, height: 108)
                    .clipShape(.rect(cornerRadius: 12))
                
                Text("Вы уверены, что хотите удалить объект из корзины?")
                    .font(AppFont.regular13)
                    .foregroundStyle(.blackPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 180)
            
            
            HStack(spacing: 8) {
                getButton("Удалить", color: .redUniversal, action: onDeleteTap)
                getButton("Вернуться", color: .whitePrimary, action: onCancelTap)
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private var nftLogo: some View {
        if let url = URL(string: nft.images.first ?? "") {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                } else if phase.error != nil {
                    nftPlaceholder
                } else {
                    LoadingView()
                }
            }
        } else {
            nftPlaceholder
        }
    }
    
    private func getButton(
        _ title: String,
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
    
    private var nftPlaceholder: some View {
        Image(.nftPlaceholder)
            .resizable()
            .scaledToFit()
    }
}

#Preview {
    ShoppingCartDeleteNftConfirmationView(
        nft: MockConstants.nfts.first!,
        onDeleteTap: {},
        onCancelTap: {}
    )
    .background(.ultraThinMaterial)
}
