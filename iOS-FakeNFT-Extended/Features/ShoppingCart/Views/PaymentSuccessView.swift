//
//  PaymentSuccessView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 31.10.2026.
//

import SwiftUI

struct PaymentSuccessView: View {
    let onBackToCartTap: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: .zero) {
            Spacer()
            
            Image(.paymentSuccess)
                .resizable()
                .scaledToFit()
                .frame(width: 278, height: 278)
            
            Text("Payment.successTitle")
                .font(AppFont.bold22)
                .foregroundStyle(.blackPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, 20)
                .padding(.horizontal, 16)
            
            Spacer()
            
            BaseButton(title: NSLocalizedString("Payment.backToCart", comment: "")) {
                onBackToCartTap()
            }
            .padding([.horizontal, .bottom], 16)
        }
        .frame(maxWidth: .infinity)
        .background(.whitePrimary)
    }
}

#Preview {
    PaymentSuccessView(onBackToCartTap: { })
}
