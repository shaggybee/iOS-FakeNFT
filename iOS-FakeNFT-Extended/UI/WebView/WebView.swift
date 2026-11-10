//
//  WebView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 30.10.2026.
//

import SwiftUI

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

enum WebViewLoadingState {
    case loading
    case loaded
    case failed
}

// MARK: - Preview

#Preview {
    if let url = URL(string: "https://practicum.yandex.ru/ios-developer/") {
        NavigationStack {
            WebView(url: url)
        }
    }
}
