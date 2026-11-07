//
//  ShoppingCartAgreementView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 30.10.2026.
//

import SwiftUI

struct ShoppingCartAgreementView: View {
    @Environment(\.dismiss) private var dismiss
    
    let agreementUrl: String
    
    var body: some View {
        content
    }
    
    @ViewBuilder
    private var content: some View {
        if let url = URL(string: agreementUrl) {
            WebView(url: url)
        } else {
            Text(NSLocalizedString("ShoppingCartAgreement.loadError", comment: ""))
                .font(AppFont.bold17)
                .foregroundStyle(.blackPrimary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.whitePrimary)
        }
    }
}

#Preview {
    ShoppingCartAgreementView(agreementUrl: "")
}
