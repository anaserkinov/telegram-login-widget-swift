//
//  TelegramLoginConfig.swift
//  TelegramLoginWidget
//
//  Created by Anas Erkinjonov on 03/03/26.
//


import Foundation
import Combine
import TelegramLoginData
import UIKit


// MARK: - TelegramLoginState

@MainActor
@Observable
public final class TelegramLoginState {
    
    struct ButtonContent {
        var text: String = ""
        var userFirstName: String? = nil
        var userPhoto: UIImage? = nil
    }
    
    
    public let config: TelegramLoginConfig

    private(set) var isLoading: Bool = true
    var buttonContent: ButtonContent = ButtonContent()

    private var lastUsedCookies: String? = nil
    private var loadTask: Task<Void, any Error>? = nil
    
    public init(config: TelegramLoginConfig) {
        self.config = config
        load()
    }

    private func load() {
        loadTask?.cancel()
        loadTask = Task {
            isLoading = true
            self.lastUsedCookies = try await TelegramLoginManager.shared.getCookies()
            let contentFlow = try await TelegramLoginManager.shared.getButtonContent(
                context: PlatformContext.companion.INSTANCE,
                config: config
            )
            for await content in contentFlow {
                self.buttonContent = ButtonContent(
                    text: content.text ?? "",
                    userFirstName: content.userFirstName,
                    userPhoto: content.userPhotoData?.toUIImage()
                )
                self.isLoading = content.dataLoadState == DataLoadState.inProgress
            }
        }
    }

    public func reload() {
        Task {
            let cookies = try await TelegramLoginManager.shared.getCookies()
            if lastUsedCookies != cookies {
                lastUsedCookies = cookies
                load()
            }
        }
    }

    public func logout() {
        Task {
            try await TelegramLoginManager.shared.logout()
            isLoading = true
            load()
        }
    }
}


public extension TelegramLoginState {
    public convenience init(
        botId: Int64,
        botUsername: String,
        websiteUrl: String,
        requestAccess: Bool = true,
        languageCode: String = "en"
    ) {
        self.init(config: TelegramLoginConfig(
            botId: botId,
            botUsername: botUsername,
            websiteUrl: websiteUrl,
            requestAccess: requestAccess,
            languageCode: languageCode
        ))
    }
}

