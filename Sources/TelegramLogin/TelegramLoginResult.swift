//
//  TelegramLoginResult.swift
//  TelegramLoginWidget
//
//  Created by Anas Erkinjonov on 26/03/26.
//

public enum TelegramLoginResult {
    case success(Success)
    case cancelled

    public struct Success {
        public let idToken: String
        public let user: TelegramUserData
    }
}

public struct TelegramUserData {
    public let iss: String
    public let aud: String
    public let sub: String
    public let iat: Int64
    public let exp: Int64
    public let id: Int64
    public let name: String
    public let preferredUsername: String?
    public let picture: String?
    public let phoneNumber: String?
    public let nonce: String?
}
