//
//  PaymentCurrencyCellView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 29.10.2026.
//

import SwiftUI

struct PaymentCurrencyCellView: View {
    let model: PaymentCurrencyCellModel
    let isSelected: Bool
    
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 4) {
                NftLogoView(url: model.imageUrl)
                    .frame(width: 36, height: 36)
                    .background(.blackPrimary)
                    .clipShape(.rect(cornerRadius: 6))
                
                VStack(alignment: .leading, spacing: .zero) {
                    Text(model.title)
                        .foregroundStyle(.blackPrimary)
                    
                    Text(model.name)
                        .foregroundStyle(.greenUniversal)
                }
                .font(AppFont.regular13)
                .lineLimit(1)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .frame(height: 46)
            .background(.lightGrey)
            .clipShape(.rect(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.blackPrimary, lineWidth: isSelected ? 1 : 0)
            }
        }
    }
}

#Preview {
    HStack {
        PaymentCurrencyCellView(
            model: PaymentCurrencyCellModel(
                id: "1",
                title: "Bitcoin",
                name: "ВТС",
                imageUrl: URL(string: "https://code.s3.yandex.net/Mobile/iOS/Currencies/Bitcoin_(BTC).png")
            ),
            isSelected: false,
            onTap: { }
        )
        
        PaymentCurrencyCellView(
            model: PaymentCurrencyCellModel(
                id: "1",
                title: "Bitcoin",
                name: "ВТС",
                imageUrl: URL(string: "https://code.s3.yandex.net/Mobile/iOS/Currencies/Bitcoin_(BTC).png")
            ),
            isSelected: true,
            onTap: { }
        )
    }
    .padding(.horizontal, 16)
}
