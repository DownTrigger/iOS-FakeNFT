import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate {
        private var isLoading: Binding<Bool>

        init(isLoading: Binding<Bool>) {
            self.isLoading = isLoading
        }

        func webView(
            _ webView: WKWebView,
            didStartProvisionalNavigation navigation: WKNavigation?
        ) {
            isLoading.wrappedValue = true
        }

        func webView(
            _ webView: WKWebView,
            didFinish navigation: WKNavigation?
        ) {
            isLoading.wrappedValue = false
        }

        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation?,
            withError error: Error
        ) {
            isLoading.wrappedValue = false
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation?,
            withError error: Error
        ) {
            isLoading.wrappedValue = false
        }
    }
}

struct WebViewScreen: View {
    let url: URL

    @State private var isLoading = true
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        WebView(url: url, isLoading: $isLoading)
            .ignoresSafeArea(edges: .bottom)
            .overlay {
                if isLoading {
                    ProgressView()
                        .tint(.fnText)
                        .frame(width: 30, height: 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
            .backButton { dismiss() }
            .toolbarBackground(Color(.fnBackground), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview() {
    if let url = URL(string: "https://example.com") {
        WebViewScreen(url: url)
    }
}
