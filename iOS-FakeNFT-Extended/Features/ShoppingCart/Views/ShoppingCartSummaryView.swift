//
//  ShoppingCartSummaryView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 20.10.2026.
//

import SwiftUI

struct ShoppingCartSummaryView: View {
    let count: Int
    let totalCost: Double
    let onPayTap: () -> Void
    
    var body: some View {
        HStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(count) NFT")
                    .font(AppFont.regular15)
                    .foregroundStyle(.blackPrimary)

                Text(getPriceString(for: totalCost))
                    .font(AppFont.bold17)
                    .foregroundStyle(.greenUniversal)
            }
            
            BaseButton(
                title: "К оплате",
                height: 44,
                action: onPayTap
            )
        }
        .padding(16)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: 12,
                topTrailingRadius: 12
            )
                .fill(.lightGrey)
        )
    }
    
    private func getPriceString(for price: Double) -> String {
        "\(price.formatted(.number.precision(.fractionLength(2)))) ETH"
    }
}

#Preview {
    ShoppingCartSummaryView(
        count: 5,
        totalCost: 234344.6,
        onPayTap: {}
    )
    .padding()
}
