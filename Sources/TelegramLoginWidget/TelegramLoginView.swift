//
//  TelegramLoginView.swift
//  TelegramLoginWidget
//
//  Created by Anas Erkinjonov on 03/03/26.
//

import Foundation
import SwiftUI
import TelegramLoginData
import WebKit

// MARK: - TelegramLoginView

public struct TelegramLoginView<Progress: View>: View {
    let config: TelegramLoginConfig
    let onResult: (TelegramLoginResult) -> Void
    @ViewBuilder var pageLoader: () -> Progress

    @State private var isLoading = true

    private var telegramUrl: String {
        var url = "https://oauth.telegram.org/auth?"
        url += "bot_id=\(config.botId)"
        url += "&origin=\(config.websiteUrl)"
        url += "&lang=\(config.languageCode)"
        if config.requestAccess {
            url += "&request_access=write"
        }
        return url
    }

    public init(
        config: TelegramLoginConfig,
        onResult: @escaping (TelegramLoginResult) -> Void,
        pageLoader: @escaping () -> Progress = {
            ProgressView()
                .progressViewStyle(.circular)
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.top, 16)
        }
    ) {
        self.config = config
        self.onResult = onResult
        self.pageLoader = pageLoader
    }

    public var body: some View {
        ZStack(alignment: .top) {
            TelegramWebView(
                url: URL(string: telegramUrl)!,
                websiteUrl: config.websiteUrl,
                onLoadingChanged: { isLoading = $0 },
                onResult: onResult
            )
            .frame(minHeight: 600)

            if isLoading {
                pageLoader()
            }
        }
    }
}

// MARK: - TelegramWebView (UIViewRepresentable)

private struct TelegramWebView: UIViewRepresentable {
    let url: URL
    let websiteUrl: String
    let onLoadingChanged: (Bool) -> Void
    let onResult: (TelegramLoginResult) -> Void

    func makeCoordinator() -> TelegramWebViewCoordinator {
        TelegramWebViewCoordinator(
            websiteUrl: websiteUrl,
            onResult: onResult,
            onLoadingChanged: onLoadingChanged
        )
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()

        config.userContentController.add(
            context.coordinator,
            name: "iOSTelegramHandler"
        )

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.backgroundColor = .white
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// MARK: - Coordinator

final class TelegramWebViewCoordinator: NSObject, WKNavigationDelegate,
    WKScriptMessageHandler
{
    private let websiteUrl: String
    private let onResult: (TelegramLoginResult) -> Void
    private let onLoadingChanged: (Bool) -> Void

    private var pushRequested = false
    private var authData: String? = nil

    init(
        websiteUrl: String,
        onResult: @escaping (TelegramLoginResult) -> Void,
        onLoadingChanged: @escaping (Bool) -> Void
    ) {
        self.websiteUrl = websiteUrl
        self.onResult = onResult
        self.onLoadingChanged = onLoadingChanged
    }

    // MARK: WKNavigationDelegate

    func webView(
        _ webView: WKWebView,
        didStartProvisionalNavigation navigation: WKNavigation!
    ) {
        onLoadingChanged(true)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        onLoadingChanged(false)
        webView.evaluateJavaScript(
            buildCancelOverrideJs(),
            completionHandler: nil
        )

        if let currentUrl = webView.url?.absoluteString,
            currentUrl.hasPrefix("https://oauth.telegram.org/auth/push")
        {
            pushRequested = true
            check()
        }
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        let urlString = url.absoluteString
        if urlString.hasPrefix(websiteUrl) {
            // Extract auth result from fragment: tgAuthResult=eyJ...
            if let fragment = url.fragment {
                authData =
                    fragment.hasPrefix("tgAuthResult=")
                    ? String(fragment.dropFirst("tgAuthResult=".count))
                    : fragment
            }
            check()
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        onLoadingChanged(false)
    }

    // MARK: WKScriptMessageHandler

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard message.name == "iOSTelegramHandler",
            let body = message.body as? String,
            body == "cancel"
        else { return }

        DispatchQueue.main.async { [weak self] in
            self?.onResult(TelegramLoginResultCancelled())
        }
    }

    // MARK: Private

    private func check() {
        guard pushRequested, let authData, !authData.isEmpty else { return }

        // Convert URL-safe base64 to standard base64
        var standardBase64 =
            authData
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let padding = standardBase64.count % 4
        if padding > 0 {
            standardBase64 += String(repeating: "=", count: 4 - padding)
        }

        guard
            let data = Data(
                base64Encoded: standardBase64,
                options: .ignoreUnknownCharacters
            ),
            let json = String(data: data, encoding: .utf8)
        else { return }

        onResult(parseJson(json))
    }

    private func parseJson(_ jsonString: String) -> TelegramLoginResult {
        guard let data = jsonString.data(using: .utf8),
            let obj = try? JSONSerialization.jsonObject(with: data)
                as? [String: Any]
        else {
            return TelegramLoginResultSuccess(
                id: 0,
                firstName: "",
                lastName: nil,
                username: nil,
                photoUrl: nil,
                authDate: 0,
                hash: ""
            )
        }

        return TelegramLoginResultSuccess(
            id: (obj["id"] as? Int64) ?? Int64(obj["id"] as? Int ?? 0),
            firstName: obj["first_name"] as? String ?? "",
            lastName: obj["last_name"] as? String,
            username: obj["username"] as? String,
            photoUrl: obj["photo_url"] as? String,
            authDate: (obj["auth_date"] as? Int64)
                ?? Int64(obj["auth_date"] as? Int ?? 0),
            hash: obj["hash"] as? String ?? ""
        )
    }
}

// MARK: - JS Injection

private func buildCancelOverrideJs() -> String {
    """
    (function() {
        window.loginCancel = function(event) {
            if (event) { event.preventDefault(); event.stopPropagation(); }
            window.webkit.messageHandlers.iOSTelegramHandler.postMessage('cancel');
            return false;
        };
        if (!window.__tgCancelClickInjected) {
            window.__tgCancelClickInjected = true;
            document.addEventListener('click', function(e) {
                var btn = e.target.closest('button');
                if (
                    btn &&
                    btn.getAttribute('onclick') &&
                    (
                        btn.getAttribute('onclick').includes('loginCancel') ||
                        btn.getAttribute('onclick').includes('declineRequest')
                    )
                ) {
                    e.preventDefault();
                    e.stopPropagation();
                    window.webkit.messageHandlers.iOSTelegramHandler.postMessage('cancel');
                }
            }, true);
        }
    })();
    """
}
