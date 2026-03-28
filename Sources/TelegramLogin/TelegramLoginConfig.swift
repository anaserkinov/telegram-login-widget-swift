//
//  TelegramLoginConfig.swift
//  TelegramLoginWidget
//
//  Created by Anas Erkinjonov on 26/03/26.
//

import Foundation

public struct TelegramLoginConfig {

    let clientId: Int64
    let redirectURI: String
    let requestDirectMessages: Bool
    let requestPhoneNumber: Bool
    let nonce: String?
    let languageCode: String?

    public init(
        clientId: Int64,
        redirectURI: String,
        requestDirectMessages: Bool = true,
        requestPhoneNumber: Bool = false,
        nonce: String? = nil,
        languageCode: String? = nil,
    ) {
        self.clientId = clientId
        self.redirectURI = redirectURI
        self.requestDirectMessages = requestDirectMessages
        self.requestPhoneNumber = requestPhoneNumber
        self.nonce = nonce
        self.languageCode = languageCode
    }

    func buildTelegramAuthUrl() -> String {
        var components = URLComponents(string: "https://oauth.telegram.org/auth")!

        var scope = "openid profile"
        if requestPhoneNumber {
            scope += " phone"
        }
        if requestDirectMessages {
            scope += " telegram:bot_access"
        }

        components.queryItems = [
            URLQueryItem(name: "response_type", value: "post_message"),
            URLQueryItem(name: "client_id", value: "\(clientId)"),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "scope", value: scope),
            nonce != nil ? URLQueryItem(name: "nonce", value: nonce) : nil,
            languageCode != nil ? URLQueryItem(name: "lang", value: languageCode) : nil,
        ].compactMap { $0 }

        return components.url!.absoluteString
    }
}
