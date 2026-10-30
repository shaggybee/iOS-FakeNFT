//
//  AppWebView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 30.10.2026.
//

import Foundation
import SwiftUI
import WebKit

struct AppWebView: UIViewRepresentable {
    // MARK: - Public properties
    @Binding var state: WebViewState
    
    let urlString: String
    
    // MARK: - Public methods
    func makeUIView(context: Context) -> some UIView {
        let webView = WKWebView()
        
        guard let url = URL(string: urlString) else {
            state = .error(URLError(.badURL))
            
            return webView
        }
        
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        
        return webView
    }
    
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(state: $state)
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        // do nothing
    }
}

