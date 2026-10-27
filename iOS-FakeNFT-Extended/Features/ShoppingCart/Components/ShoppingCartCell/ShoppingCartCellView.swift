//
//  ShoppingCartCellView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 20.10.2026.
//

import SwiftUI

struct ShoppingCartCellView: View {
    let model: ShoppingCartCellModel
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            NftLogoView(url: model.imageUrl)
                .frame(width: 108, height: 108)
                .clipShape(.rect(cornerRadius: 12))
            
            infoBlock
            
            Spacer()
            
            deleteButton
        }
        .padding(.vertical, 16)
    }
    
    private var infoBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(model.name)
                    .font(AppFont.bold17)
                    .lineLimit(1)
                    .foregroundStyle(.blackPrimary)
                
                RatingView(rating: model.rating)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Цена")
                    .font(AppFont.regular17)
                    .foregroundStyle(.blackPrimary)
                
                Text(getPriceString(for: model.price))
                    .font(AppFont.bold17)
                    .foregroundStyle(.blackPrimary)
            }
        }
    }
    
    private var deleteButton: some View {
        Button(action: onDelete) {
            Image(.cartDelete40)
                .renderingMode(.template)
                .foregroundStyle(.blackPrimary)
                .frame(width: 40, height: 40)
        }
    }
    
    private func getPriceString(for price: Double) -> String {
        "\(price.formatted(.number.precision(.fractionLength(2)))) ETH"
    }
}

#Preview {
    ShoppingCartCellView(
        model: ShoppingCartCellModel(
            id: UUID().uuidString,
            name: "Тестовый",
            rating: 2,
            price: 124.6,
            imageUrl: URL(string: "")
        ),
        onDelete: {}
    )
    .padding(.horizontal, 16)
}
