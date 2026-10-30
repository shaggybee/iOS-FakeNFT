//
//  WebView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 30.10.2026.
//

import SwiftUI
import WebKit

// MARK: - WebView

struct WebView: View {

    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss

    let url: URL

    // MARK: - Body

    var body: some View {
        WKWebViewRepresentable(url: url)
            .ignoresSafeArea(edges: .bottom)
            .navigationBarBackButtonHidden()
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
            }
    }

    // MARK: - Private Views

    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image(.backward24)
                .renderingMode(.template)
        }
        .tint(.blackPrimary)
    }
}

// MARK: - WKWebViewRepresentable

private struct WKWebViewRepresentable: UIViewRepresentable {

    // MARK: - Properties

    let url: URL

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}
}

// MARK: - Preview

#Preview {
    NavigationStack {
        WebView(url: URL(string: "https://practicum.yandex.ru/ios-developer/")!)
    }
}
