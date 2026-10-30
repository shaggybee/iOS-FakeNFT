//
//  WebViewCoordinator.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 30.10.2026.
//

import SwiftUI
import WebKit

final class WebViewCoordinator: NSObject, WKNavigationDelegate {
    // MARK: - Public properties
    @Binding var state: WebViewState
    
    init(state: Binding<WebViewState>) {
        _state = state
    }
    
    // MARK: - Public methods
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        state = .loading
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        state = .loaded
    }
    
    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        state = .error(error)
    }
    
    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        state = .error(error)
    }
}
