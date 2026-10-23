//
//  ShoppingCartPaymentView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 23.10.2026.
//

import SwiftUI

struct ShoppingCartPaymentView: View {
    @Environment(\.dismiss) private var dismis
    
    var body: some View {
        VStack {
            Text("ShoppingCartPaymentView")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.whitePrimary)
        .navigationTitle("Выберите способ оплаты")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismis()
                } label: {
                    Image(.backward24)
                        .tint(.blackPrimary)
                }
            }
        }
    }
}

#Preview {
    ShoppingCartPaymentView()
}
