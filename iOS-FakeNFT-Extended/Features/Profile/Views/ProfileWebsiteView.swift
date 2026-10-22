import SwiftUI
import WebKit

struct ProfileWebsite: Identifiable {
    let url: URL
    var id: String { url.absoluteString }
}

struct ProfileWebsiteView: View {
    @Environment(\.dismiss) private var dismiss
    let url: URL

    var body: some View {
        NavigationStack {
            ProfileWebContent(url: url)
                .navigationTitle("Сайт пользователя")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Готово") { dismiss() }
                    }
                }
        }
    }
}

private struct ProfileWebContent: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) { }
}
