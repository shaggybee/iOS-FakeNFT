//
//  ShoppingCartAgreementView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 30.10.2026.
//

import SwiftUI

struct ShoppingCartAgreementView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var webViewState: WebViewState = .loading
    
    let agreementUrl: String
    
    var body: some View {
        ZStack {
            AppWebView(state: $webViewState, urlString: agreementUrl)
                .background(.whitePrimary)
            
            if case .loading = webViewState {
                LoadingView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.whitePrimary)
            }
            
            if case .error = webViewState {
                Text("ShoppingCartAgreement.loadError")
                    .font(AppFont.bold17)
                    .foregroundStyle(.blackPrimary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.whitePrimary)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(.backward24)
                        .tint(.blackPrimary)
                }
            }
        }
        .toolbarBackground(.whitePrimary, for: .navigationBar)
    }
}

#Preview {
    ShoppingCartAgreementView(agreementUrl: "")
}
