import SwiftUI
import WebKit

struct ProfileWebsite: Identifiable {
    let url: URL
    var id: String { url.absoluteString }
}

struct ProfileWebsiteView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var model = ProfileWebsiteViewModel()
    let url: URL

    var body: some View {
        NavigationStack {
            ZStack {
                ProfileWebContent(url: url, model: model)
                    .opacity(model.state == .failed ? 0 : 1)
                    .accessibilityHidden(model.state == .failed)

                if model.state == .loading {
                    ProgressView("ProfileWebsite.loading")
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }

                if model.state == .failed {
                    VStack(spacing: 16) {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.largeTitle)
                        Text("ProfileWebsite.error.title")
                            .font(.headline)
                        Text("ProfileWebsite.error.message")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Error.repeat") { model.retry() }
                            .buttonStyle(.borderedProminent)
                            .tint(.primary)
                            .accessibilityIdentifier("profile.website.retry")
                    }
                    .padding(24)
                }
            }
                .navigationTitle("ProfileWebsite.title")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Common.done") { dismiss() }
                    }
                }
        }
    }
}

struct ProfileWebContent: UIViewRepresentable {
    let url: URL
    let model: ProfileWebsiteViewModel

    func makeCoordinator() -> Coordinator { Coordinator(model: model) }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        context.coordinator.load(url, in: uiView, reloadID: model.reloadID)
    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        uiView.navigationDelegate = nil
        uiView.stopLoading()
    }

    @MainActor
    final class Coordinator: NSObject, WKNavigationDelegate {
        private let model: ProfileWebsiteViewModel
        private var loadedID: Int?
        private var currentNavigation: WKNavigation?

        init(model: ProfileWebsiteViewModel) { self.model = model }

        func load(_ url: URL, in webView: WKWebView, reloadID: Int) {
            guard loadedID != reloadID else { return }
            loadedID = reloadID
            currentNavigation = webView.load(URLRequest(url: url))
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            currentNavigation = navigation
            model.startedLoading()
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            guard navigation === currentNavigation else { return }
            model.finishedLoading()
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            handleFailure(navigation, error: error)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            handleFailure(navigation, error: error)
        }

        private func handleFailure(_ navigation: WKNavigation?, error: Error) {
            guard navigation === currentNavigation else { return }
            model.failedLoading(with: error)
        }
    }
}
