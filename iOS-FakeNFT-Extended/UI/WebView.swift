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
    @State private var loadingState: WebViewLoadingState = .loading
    @State private var reloadToken = 0

    let url: URL

    // MARK: - Body

    var body: some View {
        WKWebViewRepresentable(
            url: url,
            reloadToken: reloadToken,
            loadingState: $loadingState
        )
        .ignoresSafeArea(edges: .bottom)
        .overlay {
            overlay
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                backButton
            }
        }
    }

    // MARK: - Private Views

    @ViewBuilder
    private var overlay: some View {
        switch loadingState {
        case .loading:
            LoadingView()
                .background(.whitePrimary)
        case .failed:
            ErrorStateView(
                message: String(localized: "WebView.loadingError"),
                onRetry: retryButtonTapped
            )
            .padding(.horizontal, Constants.horizontalPadding)
            .background(.whitePrimary)
        case .loaded:
            EmptyView()
        }
    }

    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image(.backward24)
                .renderingMode(.template)
        }
        .tint(.blackPrimary)
    }

    // MARK: - Private Methods

    private func retryButtonTapped() {
        loadingState = .loading
        reloadToken += 1
    }
}

// MARK: - Constants

private extension WebView {
    enum Constants {
        static let horizontalPadding: CGFloat = 16
    }
}

// MARK: - WebViewLoadingState

private enum WebViewLoadingState {
    case loading
    case loaded
    case failed
}

// MARK: - WKWebViewRepresentable

private struct WKWebViewRepresentable: UIViewRepresentable {

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

// MARK: - Preview

#Preview {
    NavigationStack {
        WebView(url: URL(string: "https://practicum.yandex.ru/ios-developer/")!)
    }
}
