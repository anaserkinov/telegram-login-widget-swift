//
//  TelegramLoginView.swift
//  TelegramLoginWidget
//
//  Created by Anas Erkinjonov on 03/03/26.
//

import Foundation
import SwiftUI
import WebKit

// MARK: - WebViewHolder

/// Holds the WKWebView instance across SwiftUI recompositions.

@Observable
private final class WebViewHolder {
    let webView: WKWebView

    init() {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        webView = WKWebView(frame: .zero, configuration: configuration)
    }
}

// MARK: - TelegramLoginView

public struct TelegramLoginView<Progress: View>: View {
    let config: TelegramLoginConfig
    let onResult: (TelegramLoginResult) -> Void
    @ViewBuilder var pageLoader: () -> Progress

    @State private var holder = WebViewHolder()
    @State private var isLoading = true
    @State private var canGoBack = false

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
                webView: holder.webView,
                url: URL(string: config.buildTelegramAuthUrl())!,
                redirectURI: config.redirectURI,
                onLoadingChanged: { isLoading = $0 },
                onCanGoBackChanged: { canGoBack = $0 },
                onResult: onResult
            )

            HStack {
                if canGoBack {
                    backButton
                }
                Spacer()
            }

            if isLoading {
                pageLoader()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var backButton: some View {
        let action = {
            holder.webView.goBack()
            return
        }
        let label = Image(systemName: "chevron.left")
            .font(.system(size: 18, weight: .semibold))

        if #available(iOS 26.0, *) {
            Button(action: action) { label }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .padding(.all, 14)
        } else {
            Button(action: action) { label }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.circle)
                .padding(.all, 14)
        }
    }
}

// MARK: - TelegramWebView (UIViewRepresentable)

private struct TelegramWebView: UIViewRepresentable {
    let webView: WKWebView
    let url: URL
    let redirectURI: String
    let onLoadingChanged: (Bool) -> Void
    let onCanGoBackChanged: (Bool) -> Void
    let onResult: (TelegramLoginResult) -> Void

    func makeCoordinator() -> TelegramWebViewCoordinator {
        TelegramWebViewCoordinator(
            redirectURI: redirectURI,
            onResult: onResult,
            onLoadingChanged: onLoadingChanged,
            onCanGoBackChanged: onCanGoBackChanged
        )
    }

    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator

        if webView.url == nil {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        context.coordinator.onResult = onResult
        context.coordinator.onLoadingChanged = onLoadingChanged
        context.coordinator.onCanGoBackChanged = onCanGoBackChanged
    }
}

// MARK: - Coordinator

final class TelegramWebViewCoordinator: NSObject, WKNavigationDelegate {

    private let redirectURI: String
    var onResult: (TelegramLoginResult) -> Void
    var onLoadingChanged: (Bool) -> Void
    var onCanGoBackChanged: (Bool) -> Void

    init(
        redirectURI: String,
        onResult: @escaping (TelegramLoginResult) -> Void,
        onLoadingChanged: @escaping (Bool) -> Void,
        onCanGoBackChanged: @escaping (Bool) -> Void
    ) {
        self.redirectURI = redirectURI
        self.onResult = onResult
        self.onLoadingChanged = onLoadingChanged
        self.onCanGoBackChanged = onCanGoBackChanged
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        onLoadingChanged(true)
        onCanGoBackChanged(webView.canGoBack)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        onLoadingChanged(false)
        onCanGoBackChanged(webView.canGoBack)
    }

    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        onLoadingChanged(false)
        onCanGoBackChanged(webView.canGoBack)
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        onCanGoBackChanged(webView.canGoBack)
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

        // Handle tg:// deep links — open Telegram app or prompt install
        if urlString.hasPrefix("tg:") {
            UIApplication.shared.open(url, options: [:]) { success in
                if !success {
                    UIApplication.shared.open(
                        URL(string: "itms-apps://itunes.apple.com/app/id686449807")!
                    )
                }
            }
            decisionHandler(.cancel)
            return
        }

        // Handle redirect URI — extract and parse auth result
        if urlString.hasPrefix(redirectURI) {
            if let fragment = url.fragment {
                let authData =
                    fragment.hasPrefix("tgAuthResult=")
                    ? String(fragment.dropFirst("tgAuthResult=".count))
                    : fragment
                onResult(parse(authData: authData))
            } else {
                onResult(.cancelled)
            }
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }

    // MARK: - JWT Parsing

    private func decodeJwtPayload(token: String) -> [String: Any]? {
        let parts = token.split(separator: ".")
        guard parts.count == 3 else { return nil }

        var payload = String(parts[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let remainder = payload.count % 4
        if remainder != 0 {
            payload += String(repeating: "=", count: 4 - remainder)
        }

        guard let data = Data(base64Encoded: payload, options: .ignoreUnknownCharacters) else {
            return nil
        }

        return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    }

    private func parse(authData: String?) -> TelegramLoginResult {
        guard let authData, !authData.isEmpty else {
            return .cancelled
        }

        var idToken = String(authData)
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let remainder = idToken.count % 4
        if remainder != 0 {
            idToken += String(repeating: "=", count: 4 - remainder)
        }

        guard let idTokenData = Data(base64Encoded: idToken, options: .ignoreUnknownCharacters) else {
            return .cancelled
        }

        guard let idToken = String(data: idTokenData, encoding: .utf8) else {
            return .cancelled
        }

        guard let json = decodeJwtPayload(token: idToken) else {
            return .cancelled
        }

        guard
            let iss = json["iss"] as? String,
            let aud = json["aud"] as? String,
            let sub = json["sub"] as? String,
            let iatRaw = json["iat"] as? Int,
            let expRaw = json["exp"] as? Int,
            let name = json["name"] as? String
        else {
            return .cancelled
        }

        let id: Int64
        if let idInt = json["id"] as? Int {
            id = Int64(idInt)
        } else if let idStr = json["id"] as? String, let idParsed = Int64(idStr) {
            id = idParsed
        } else {
            return .cancelled
        }

        let user = TelegramUserData(
            iss: iss,
            aud: aud,
            sub: sub,
            iat: Int64(iatRaw),
            exp: Int64(expRaw),
            id: id,
            name: name,
            preferredUsername: json["preferred_username"] as? String,
            picture: json["picture"] as? String,
            phoneNumber: json["phone_number"] as? String,
            nonce: json["nonce"] as? String
        )

        return .success(.init(idToken: authData, user: user))
    }
}
