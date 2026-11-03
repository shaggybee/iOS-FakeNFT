//
//  WKWebViewRepresentable.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 03.11.2026.
//

import SwiftUI
import WebKit

struct WKWebViewRepresentable: UIViewRepresentable {

    // MARK: - Properties

    let url: URL
    let reloadToken: Int
    @Binding var loadingState: WebViewLoadingState

    // MARK: - UIViewRepresentable

    func makeCoordinator() -> Coordinator {
        Coordinator(loadingState: $loadingState, reloadToken: reloadToken)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard context.coordinator.reloadToken != reloadToken else { return }
        context.coordinator.reloadToken = reloadToken
        webView.load(URLRequest(url: url))
    }
}

// MARK: - Coordinator

extension WKWebViewRepresentable {
    final class Coordinator: NSObject, WKNavigationDelegate {

        // MARK: - Properties

        @Binding private var loadingState: WebViewLoadingState
        var reloadToken: Int

        // MARK: - Init

        init(loadingState: Binding<WebViewLoadingState>, reloadToken: Int) {
            _loadingState = loadingState
            self.reloadToken = reloadToken
        }

        // MARK: - WKNavigationDelegate

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            loadingState = .loaded
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            handleFailure(error)
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            handleFailure(error)
        }

        // MARK: - Private Methods

        private func handleFailure(_ error: Error) {
            guard (error as? URLError)?.code != .cancelled, loadingState == .loading else { return }
            loadingState = .failed
        }
    }
}
